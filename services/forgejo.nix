# Forgejo on yggdrasil in a MicroVM of its own, with `vars.forgejo.runners`
# runner MicroVMs beside it. forge.trkm.io is public, so nothing the forge
# serves can be a way into the host, and the runners reach the forge and the
# internet and nothing else — not the LAN, not the tailnet, not each other.
{
  config,
  lib,
  ...
}: let
  inherit (config.vars.global) vars;

  endpoint = {
    host = "10.66.1.10";
    port = 3000;
  };

  route = config.flake.lib.makePublicRoute endpoint;
  hostname = config.flake.lib.routeHostname vars "forge" route;

  # The guest of `index = 1`: the feature puts every guest at .10 of its own /24.
  internalUrl = "http://${endpoint.host}:${toString endpoint.port}";

  # A way in from the host: root by key, over the guest's own bridge.
  admin = {
    services.openssh.enable = true;

    users.users.root.openssh.authorizedKeys.keys = [config.vars.users.tm.publicKey];

    networking.firewall.allowedTCPPorts = [22];
  };

  forgejo = _: {
    imports = [admin];

    services.forgejo = {
      enable = true;
      lfs.enable = true;

      settings = {
        DEFAULT.APP_NAME = "trkm forge";

        server = {
          DOMAIN = hostname;
          ROOT_URL = "https://${hostname}/";
          HTTP_ADDR = "0.0.0.0";
          HTTP_PORT = endpoint.port;
          # Git over ssh stays off: clones are https, and 22 is the way in.
          DISABLE_SSH = true;
        };

        actions.ENABLED = true;
        security.INSTALL_LOCK = true;
        service.DISABLE_REGISTRATION = true;
        session.COOKIE_SECURE = true;
      };
    };

    # Repositories, the database and Forgejo's own generated secrets.
    microvm.volumes = [
      {
        image = "/var/lib/microvms/forgejo/data.img";
        mountPoint = "/var/lib/forgejo";
        size = 20480;
      }
    ];

    networking.firewall.allowedTCPPorts = [endpoint.port];
  };

  runners =
    lib.genList (i: let
      name = "runner-${toString i}";
    in {
      inherit name;

      value = {
        index = i + 2;
        # 2 GiB makes qemu hang; a job needs room to build in.
        mem = 2560;

        guest = {pkgs, ...}: {
          imports = [admin];

          services.gitea-actions-runner = {
            package = pkgs.forgejo-runner;

            instances.${name} = {
              enable = true;
              inherit name;
              url = internalUrl;
              tokenFile = "/run/forgejo-runner/token";
              labels = ["native:host"];
              hostPackages = with pkgs; [bash coreutils curl gitMinimal nix nodejs];
            };
          };

          # The registration token, read-only, with nothing beside it.
          microvm.shares = [
            {
              proto = "9p";
              tag = "runner-token";
              source = "/var/lib/forgejo-runner";
              mountPoint = "/run/forgejo-runner";
              readOnly = true;
            }
          ];

          # Jobs build with nix, so the shared store needs a writable layer.
          microvm.writableStoreOverlay = "/nix/.rw-store";

          microvm.volumes = [
            {
              image = "/var/lib/microvms/${name}/store.img";
              mountPoint = "/nix/.rw-store";
              size = 8192;
            }
            {
              # The registration, so a reboot doesn't add a second runner.
              image = "/var/lib/microvms/${name}/state.img";
              mountPoint = "/var/lib/gitea-runner";
              size = 128;
            }
          ];

          nix.settings.experimental-features = ["nix-command" "flakes"];

          # systemd reads the token when the unit starts.
          systemd.services."gitea-runner-${name}".unitConfig.RequiresMountsFor = ["/run/forgejo-runner"];
        };
      };
    })
    vars.forgejo.runners;

  nixos = {
    my.microvms.guests =
      {
        forgejo = {
          index = 1;
          mem = 3072;
          guest = forgejo;
        };
      }
      // lib.listToAttrs runners;

    # The one secret the runners need, readable by the hypervisor and by them.
    systemd.services.forgejo-runner-token = lib.mkIf (runners != []) {
      wantedBy = ["multi-user.target"];
      before = map (guest: "microvm@${guest.name}.service") runners;

      serviceConfig.Type = "oneshot";

      script = ''
        install -d -m 0750 -o root -g kvm /var/lib/forgejo-runner
        install -m 0440 -o root -g kvm /var/lib/secrets/forgejo-runner-token /var/lib/forgejo-runner/token
      '';
    };

    # The forge, and only the forge: every other destination is private space.
    networking.firewall.extraForwardRules =
      lib.concatMapStrings (guest: ''
        iifname "mv-${guest.name}" ip daddr ${endpoint.host} tcp dport ${toString endpoint.port} accept
      '')
      runners;
  };
in {
  my.services.forgejo = {
    host = "yggdrasil";
    modules = [config.features.nixos.platform.microvm nixos];
    routes.forge = route;
  };
}

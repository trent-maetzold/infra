# Forgejo in a NixOS container on the host's network, with PostgreSQL and
# Valkey beside it, and an Actions runner in a private-network container running
# jobs in Docker. The forge makes and registers the runner's secret, in a
# directory both containers mount. On yggdrasil at fj.ts.trkm.io, mail through
# Proton.
{config, ...}: let
  inherit (config.flake.lib) makeServiceRoute;
  inherit (config.flake.modules.nixos) state-version;

  ports = {
    http = 3000;
    ssh = 2222;
  };

  tokens = "/var/lib/forgejo-runner";
  runnerIp = "10.233.0.2";

  # The runner's secret is 40 hex characters; its UUID is the first 16 as bytes.
  prefix = "0000000000000001";
  uuid = "30303030-3030-3030-3030-303030303031";

  modules.nixos = {lib, ...}: {
    systemd.tmpfiles.rules = ["d ${tokens} 0700 root root -"];

    networking.nat = {
      enable = true;
      internalInterfaces = ["ve-runner"];
    };

    containers.forgejo = {
      autoStart = true;

      bindMounts.${tokens} = {
        hostPath = tokens;
        isReadOnly = false;
      };

      config = {
        config,
        pkgs,
        ...
      }: let
        cfg = config.services.forgejo;
        redis = "redis+socket://${config.services.redis.servers.forgejo.unixSocket}";
      in {
        imports = [state-version];

        services.forgejo = {
          enable = true;
          lfs.enable = true;

          database = {
            type = "postgres";
            createDatabase = true;
          };

          settings = {
            server = {
              HTTP_ADDR = lib.mkDefault "127.0.0.1";
              HTTP_PORT = ports.http;
              START_SSH_SERVER = true;
              SSH_LISTEN_HOST = lib.mkDefault "127.0.0.1";
              SSH_LISTEN_PORT = ports.ssh;
              SSH_PORT = ports.ssh;
              OFFLINE_MODE = true;
            };

            service = {
              DISABLE_REGISTRATION = true;
              DEFAULT_KEEP_EMAIL_PRIVATE = true;
            };

            actions.ENABLED = true;

            cache = {
              ADAPTER = "redis";
              HOST = redis;
            };

            queue = {
              TYPE = "redis";
              CONN_STR = redis;
            };

            session = {
              PROVIDER = "redis";
              PROVIDER_CONFIG = redis;
            };
          };
        };

        services.redis = {
          package = pkgs.valkey;

          servers.forgejo = {
            enable = true;
            port = 0;
          };
        };

        users.users.${cfg.user}.extraGroups = ["redis-forgejo"];

        # Registration is idempotent; retries until the forge has migrated its database.
        systemd.services.forgejo-runner-register = {
          after = ["forgejo.service"];
          requires = ["forgejo.service"];
          wantedBy = ["multi-user.target"];
          environment = {
            FORGEJO_WORK_DIR = cfg.stateDir;
            FORGEJO_CUSTOM = cfg.customDir;
          };
          serviceConfig = {
            Type = "oneshot";
            Restart = "on-failure";
            RestartSec = 10;
          };
          script = ''
            umask 077
            [ -s ${tokens}/token ] || echo "${prefix}$(${lib.getExe pkgs.openssl} rand -hex 12)" > ${tokens}/token
            ${pkgs.util-linux}/bin/runuser -u ${cfg.user} -- ${lib.getExe cfg.package} forgejo-cli actions register --name runner --secret "$(<${tokens}/token)"
          '';
        };
      };
    };

    # Docker in nspawn needs every capability and the syscalls it filters.
    containers.runner = {
      autoStart = true;
      privateNetwork = true;
      hostAddress = "10.233.0.1";
      localAddress = runnerIp;
      additionalCapabilities = ["all"];
      extraFlags = ["--system-call-filter=@keyring" "--system-call-filter=bpf"];
      bindMounts.${tokens}.hostPath = tokens;

      config = {
        imports = [state-version];

        virtualisation.docker.enable = true;

        services.forgejo-runner.instances.default = {
          enable = true;
          settings.server.connections.default.uuid = uuid;
          secrets.server.connections.default.token_url = "${tokens}/token";
          settings.runner.labels = lib.mkDefault ["docker:docker://node:22-bookworm" "ubuntu-latest:docker://node:22-bookworm"];
        };
      };
    };
  };

  ip = config.hosts.yggdrasil.ips.tailnet;
  router = config.hosts.heimdall.ips.tailnet;
  route = makeServiceRoute {
    hostname = "fj.ts.trkm.io";
    inherit ip;
    port = ports.http;
  };

  hosts.yggdrasil = {config, ...}: let
    smtp = config.sops.secrets.forgejo-smtp-token.path;
  in {
    sops.secrets.forgejo-smtp-token.key = "forgejo/smtp-token";

    persistence.dirs."/var/lib/nixos-containers".snapshots = true;

    # The runner and its jobs reach the forge through the router, over the tailnet.
    networking.nat.extraCommands = "iptables -t nat -A nixos-nat-post -s ${runnerIp} -o tailscale0 -j MASQUERADE";

    containers.forgejo = {
      bindMounts.${smtp}.hostPath = smtp;

      config.services.forgejo = {
        secrets.mailer.PASSWD = smtp;

        settings = {
          server = {
            DOMAIN = route.hostname;
            ROOT_URL = "https://${route.hostname}/";
            SSH_DOMAIN = route.hostname;
            HTTP_ADDR = ip;
            SSH_LISTEN_HOST = ip;
          };

          service.NO_REPLY_ADDRESS = "noreply.${route.hostname}";

          mailer = {
            ENABLED = true;
            PROTOCOL = "smtp+starttls";
            SMTP_ADDR = "smtp.protonmail.ch";
            SMTP_PORT = 587;
            FROM = "Forgejo <noreply@trkm.io>";
            USER = "noreply@trkm.io";
          };
        };
      };
    };

    containers.runner.config.services.forgejo-runner.instances.default.settings = {
      server.connections.default.url = "https://${route.hostname}/";
      container.options = "--add-host=${route.hostname}:${router}";
    };
  };
in {
  # Flake Modules
  flake.modules.nixos.forgejo = modules.nixos;

  # NixOS Configuration Modules
  flake.nixosModules.yggdrasil.imports = [
    config.flake.modules.nixos.forgejo
    hosts.yggdrasil
  ];

  # Routes
  routes = {
    fj = route;

    fj-ssh = makeServiceRoute {
      inherit (route) hostname;
      inherit ip;
      port = ports.ssh;
      scheme = "tcp";
    };
  };
}

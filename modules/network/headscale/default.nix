# Headscale with headplane at /admin, on heimdall behind traefik; every tailnet
# route resolves to heimdall.
{
  config,
  lib,
  ...
}: let
  makeTailnetDNS = import ./_lib/make-tailnet-dns.nix {inherit lib;};
in let
  inherit (config) routes;
  inherit (config.hosts) heimdall;

  modules.nixos = {
    config,
    tailnet,
    headplane-cookie-secret,
    ...
  }: {
    services = {
      headscale = {
        enable = true;

        settings = {
          server_url = tailnet.loginServer;

          dns = {
            magic_dns = true;
            base_domain = tailnet.domain;
            nameservers.global = ["1.1.1.1" "9.9.9.9"];
          };
        };
      };

      headplane = {
        enable = true;

        settings = {
          server = {
            base_url = "${tailnet.loginServer}/admin";
            cookie_secret_path = headplane-cookie-secret;
          };

          headscale.config_path = config.services.headscale.configFile;
        };
      };
    };
  };

  hosts.heimdall = {
    config,
    pkgs,
    ...
  }: let
    inherit (config.services.headscale.settings) server_url;
    loginHost = lib.removePrefix "https://" server_url;
  in {
    services.headscale.settings = {
      dns.extra_records = makeTailnetDNS heimdall.ips.tailnet routes;

      # tm reaches every node, and Tailscale SSH takes tm into each as tm or
      # trent; heimdall is `tag:edge`, so SSH is never from it.
      policy.path = pkgs.writeText "policy.json" (builtins.toJSON {
        tagOwners."tag:edge" = ["tm@"];

        acls = [
          {
            action = "accept";
            src = ["*"];
            dst = ["*:*"];
          }
        ];

        ssh = [
          {
            action = "accept";
            src = ["autogroup:member"];
            dst = ["autogroup:self"];
            users = ["tm" "trent"];
          }
          {
            action = "accept";
            src = ["autogroup:member"];
            dst = ["tag:edge"];
            users = ["tm"];
          }
        ];
      });
    };

    # Applies when heimdall registers; tag an already registered heimdall
    # with `headscale nodes tag`.
    services.tailscale.extraUpFlags = ["--advertise-tags=tag:edge"];

    services.traefik.dynamicConfigOptions.http = {
      # Clients never ask for /, which headscale answers with an empty page.
      middlewares.headplane.redirectRegex = {
        regex = ".*";
        replacement = "${server_url}/admin";
      };

      routers = {
        root = {
          rule = "Host(`${loginHost}`) && Path(`/`)";
          service = "noop@internal";
          middlewares = ["headplane"];
        };

        headplane = {
          rule = "Host(`${loginHost}`) && PathPrefix(`/admin`)";
          service = "headplane";
        };

        headscale = {
          rule = "Host(`${loginHost}`)";
          service = "headscale";
        };
      };

      services = {
        headplane.loadBalancer.servers = [{url = "http://127.0.0.1:${toString config.services.headplane.settings.server.port}";}];
        headscale.loadBalancer.servers = [{url = "http://127.0.0.1:${toString config.services.headscale.port}";}];
      };
    };
  };
in {
  # Flake Modules
  flake.modules.nixos.headscale = modules.nixos;

  # NixOS Configuration Modules
  flake.nixosModules.heimdall.imports = [
    config.flake.modules.nixos.headscale
    hosts.heimdall
  ];
}

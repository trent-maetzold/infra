# Headscale with headplane at /admin, on heimdall behind traefik; every tailnet
# route resolves to heimdall.
{
  config,
  lib,
  ...
}: let
  records =
    lib.mapAttrsToList (_: route: {
      name = route.hostname;
      type = "A";
      value = config.hosts.heimdall.ips.tailnet;
    })
    (lib.filterAttrs (_: route: route.dns == "tailnet") config.routes);

  modules.nixos = {config, ...}: let
    inherit (config) vars;
  in {
    services = {
      headscale = {
        enable = true;

        settings = {
          server_url = vars.tailnet.loginServer;

          dns = {
            magic_dns = true;
            base_domain = vars.tailnet.domain;
            nameservers.global = ["1.1.1.1" "9.9.9.9"];
          };
        };
      };

      headplane = {
        enable = true;

        settings = {
          server = {
            base_url = "${vars.tailnet.loginServer}/admin";
            cookie_secret_path = "/var/lib/secrets/headplane-cookie-secret";
          };

          headscale.config_path = config.services.headscale.configFile;
        };
      };
    };
  };

  hosts.heimdall = {config, ...}: let
    inherit (config.services.headscale.settings) server_url;
    loginHost = lib.removePrefix "https://" server_url;
  in {
    services.headscale.settings.dns.extra_records = records;

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

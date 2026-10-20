# Heimdall's tailnet control plane; names every tailnet route after the host serving it.
{config, ...}: let
  inherit (config) my;
  inherit (config.flake.lib) routeHostname;
  inherit (config.vars) hosts;

  nixos = {
    config,
    lib,
    ...
  }: let
    inherit (config) vars;
    tailnetRoutes = lib.filterAttrs (_: route: route.kind == "tailnet") my.routes;
    loginHost = lib.removePrefix "https://" vars.tailnet.loginServer;
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

            extra_records =
              lib.mapAttrsToList (name: route: {
                name = routeHostname vars name route;
                type = "A";
                value = hosts.${route.host}.tailnetIp;
              })
              tailnetRoutes;
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

      caddy.virtualHosts.${loginHost}.extraConfig = ''
        handle /admin* {
          reverse_proxy 127.0.0.1:${toString config.services.headplane.settings.server.port}
        }
        handle {
          reverse_proxy 127.0.0.1:${toString config.services.headscale.port}
        }
      '';
    };
  };
in {
  my.services.headscale = {
    host = "heimdall";
    modules = [nixos];
  };
}

# Heimdall's tailnet control plane; points every tailnet route at the router.
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
                value = hosts.${my.services.traefik.host}.tailnetIp;
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

      traefik.dynamicConfigOptions.http = {
        routers = {
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
  };
in {
  my.services.headscale = {
    host = "heimdall";
    modules = [nixos];
  };
}

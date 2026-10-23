# Traefik serving every non-private route: tailnet routes under the tailnet
# domain and only to the tailnet, public ones under the domain.
{config, ...}: let
  inherit (config) my;
  inherit (config.flake.lib) routeHostname;

  nixos = {
    config,
    lib,
    ...
  }: let
    inherit (config) vars;

    routes = lib.filterAttrs (_: route: route.kind != "private") my.routes;
  in {
    networking.firewall.allowedTCPPorts = [80 443];

    systemd.services.traefik.environment.CF_DNS_API_TOKEN_FILE = "/var/lib/secrets/cf-dns-api-token";

    services.traefik = {
      enable = true;

      staticConfigOptions = {
        api = {
          dashboard = true;
          disableDashboardAd = true;
        };

        log.level = "INFO";
        accessLog = {};

        entryPoints = {
          web = {
            address = ":80";
            http.redirections.entryPoint.to = "websecure";
          };

          websecure = {
            address = ":443";
            asDefault = true;
            http.tls.certResolver = "cloudflare";
          };
        };

        certificatesResolvers.cloudflare.acme = {
          email = vars.acmeEmail;
          storage = "${config.services.traefik.dataDir}/acme.json";

          dnsChallenge = {
            provider = "cloudflare";
            # MagicDNS answers SOA for tailnet names with NOTIMP, hiding the Cloudflare zone
            resolvers = ["1.1.1.1:53"];
          };
        };
      };

      dynamicConfigOptions.http = {
        middlewares.tailnet.ipAllowList.sourceRange = [vars.tailnet.subnet];

        routers =
          lib.mapAttrs (name: route: {
            rule = "Host(`${routeHostname vars name route}`)";
            service = name;
            middlewares = lib.optional (route.kind == "tailnet") "tailnet";
          })
          routes
          // {
            api = {
              rule = "Host(`traefik.${vars.domain}`) && (PathPrefix(`/api`) || PathPrefix(`/dashboard`))";
              service = "api@internal";
            };
          };

        services = lib.mapAttrs (_: route: {loadBalancer.servers = [{inherit (route.endpoint) url;}];}) routes;
      };
    };
  };
in {
  # Features
  features.nixos.network.traefik = nixos;
}

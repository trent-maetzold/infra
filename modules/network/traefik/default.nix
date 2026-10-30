# Traefik on heimdall, routing every route: tailnet ones only to the tailnet.
{
  config,
  lib,
  ...
}: let
  makeTraefikHttp = import ./_lib/make-traefik-http.nix {inherit lib;};
in let
  inherit (config) routes;

  # `api.insecure` serves the dashboard here; it is routed like any service.
  dashboard = {
    ip = "127.0.0.1";
    port = 8081;
  };

  modules.nixos = {
    config,
    acmeEmail,
    tailnet,
    cf-dns-api-token,
    ...
  }: {
    networking.firewall.allowedTCPPorts = [80 443];

    systemd.services.traefik.environment.CF_DNS_API_TOKEN_FILE = cf-dns-api-token;

    services.traefik = {
      enable = true;

      staticConfigOptions = {
        api = {
          insecure = true;
          disableDashboardAd = true;
        };

        log.level = "INFO";
        accessLog = {};

        entryPoints = {
          web = {
            address = ":80";
            http.redirections.entryPoint.to = "websecure";
          };

          traefik.address = "${dashboard.ip}:${toString dashboard.port}";

          websecure = {
            address = ":443";
            asDefault = true;
            http.tls.certResolver = "cloudflare";
          };
        };

        certificatesResolvers.cloudflare.acme = {
          email = acmeEmail;
          storage = "${config.services.traefik.dataDir}/acme.json";

          dnsChallenge = {
            provider = "cloudflare";
            # MagicDNS answers SOA for tailnet names with NOTIMP, hiding the Cloudflare zone
            resolvers = ["1.1.1.1:53"];
          };
        };
      };

      dynamicConfigOptions.http.middlewares.tailnet.ipAllowList.sourceRange = [tailnet.subnet];
    };
  };

  route = {
    hostname = "traefik.ts.trkm.io";
    endpoint = dashboard;
  };

  hosts.heimdall = {config, ...}: {
    sops.secrets.cf-dns-api-token = {
      sopsFile = ./secrets.yaml;
      owner = "traefik";
    };

    _module.args.cf-dns-api-token = config.sops.secrets.cf-dns-api-token.path;

    services.traefik.dynamicConfigOptions.http = lib.mkMerge [
      (makeTraefikHttp routes)

      # The dashboard's assets are relative, so it only works under /dashboard/.
      {
        middlewares.dashboard.redirectRegex = {
          regex = "^(https?://[^/]+)/(dashboard)?$";
          replacement = "\${1}/dashboard/";
          permanent = true;
        };

        routers.traefik.middlewares = ["dashboard"];
      }
    ];
  };
in {
  # Flake Modules
  flake.modules.nixos.traefik = modules.nixos;

  # NixOS Configuration Modules
  flake.nixosModules.heimdall.imports = [
    config.flake.modules.nixos.traefik
    hosts.heimdall
  ];

  # Routes
  routes.traefik = route;
}

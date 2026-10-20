# Traefik serving every non-private route of the host it runs on: tailnet
# routes under the tailnet domain and only to the tailnet, public ones under the
# domain.
{config, ...}: let
  inherit (config) my;
  inherit (config.flake.lib) routeHostname;

  nixos = {
    config,
    lib,
    pkgs,
    quadlet-nix,
    ...
  }: let
    inherit (config) vars;
    inherit (config.virtualisation.quadlet) volumes;

    routes = lib.filterAttrs (_: route: route.host == config.networking.hostName && route.kind != "private") my.routes;

    dynamic = (pkgs.formats.yaml {}).generate "traefik-dynamic.yml" {
      http = {
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

        services = lib.mapAttrs (_: route: {loadBalancer.servers = [{url = route.endpoint.url;}];}) routes;
      };
    };
  in {
    imports = [quadlet-nix.nixosModules.quadlet];

    virtualisation.podman.enable = true;

    networking.firewall.allowedTCPPorts = [80 443];

    virtualisation.quadlet = {
      autoEscape = true;

      volumes.traefik_letsencrypt.volumeConfig = {};

      containers.traefik = {
        containerConfig = {
          name = "traefik";
          image = "docker.io/library/traefik:v3";
          pull = "newer";
          networks = ["host"];

          volumes = [
            "${volumes.traefik_letsencrypt.ref}:/var/lib/traefik/letsencrypt"
            "/var/lib/secrets/cf-dns-api-token:/var/lib/secrets/cf-dns-api-token:ro"
            "${dynamic}:/etc/traefik/dynamic.yml:ro"
          ];

          environments = {
            TZ = "America/Chicago";
            CF_API_EMAIL = vars.acmeEmail;
            CF_DNS_API_TOKEN_FILE = "/var/lib/secrets/cf-dns-api-token";
          };

          exec = [
            "--api.dashboard=true"
            "--api.disableDashboardAd=true"
            "--log.level=INFO"
            "--accesslog=true"
            "--providers.file.filename=/etc/traefik/dynamic.yml"
            "--entryPoints.websecure.address=:443"
            "--entryPoints.websecure.asDefault=true"
            "--entryPoints.websecure.http.tls.certResolver=cloudflare"
            "--certificatesResolvers.cloudflare.acme.email=${vars.acmeEmail}"
            "--certificatesResolvers.cloudflare.acme.storage=/var/lib/traefik/letsencrypt/acme.json"
            "--certificatesResolvers.cloudflare.acme.dnsChallenge=true"
            "--certificatesResolvers.cloudflare.acme.dnsChallenge.provider=cloudflare"
            # MagicDNS answers SOA for tailnet names with NOTIMP, hiding the Cloudflare zone
            "--certificatesResolvers.cloudflare.acme.dnsChallenge.resolvers=1.1.1.1:53"
            "--serverstransport.insecureSkipVerify=true"
          ];
        };

        serviceConfig = {
          Restart = "always";
          RestartSec = "10";
        };
      };
    };
  };
in {
  # Features
  features.nixos.network.traefik = nixos;
}

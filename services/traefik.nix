# Yggdrasil's ingress: traefik serves every non-private route of its host.
{config, ...}: let
  inherit (config) my;

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
    hostname = name: route: "${name}.${
      if route.kind == "tailnet"
      then vars.tailnet.domain
      else vars.domain
    }";

    dynamic = (pkgs.formats.yaml {}).generate "traefik-dynamic.yml" {
      http = {
        middlewares.tailnet.ipAllowList.sourceRange = [vars.tailnet.subnet];

        routers =
          lib.mapAttrs (name: route: {
            rule = "Host(`${hostname name route}`)";
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
  my.services.traefik = {
    host = "yggdrasil";
    modules = [nixos];
  };
}

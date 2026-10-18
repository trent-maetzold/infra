{
  config,
  pkgs,
  quadlet-nix,
  ...
}: let
  inherit (config) vars;
  inherit (config.virtualisation.quadlet) volumes;

  # Host services on loopback, routed by name and kept to the tailnet.
  dynamic = (pkgs.formats.yaml {}).generate "traefik-dynamic.yml" {
    http = {
      middlewares.tailnet.ipAllowList.sourceRange = [vars.tailnet.subnet];

      routers.hermes = {
        rule = "Host(`hermes.${vars.tailnet.domain}`)";
        middlewares = ["tailnet"];
        service = "hermes";
      };

      services.hermes.loadBalancer.servers = [{url = "http://127.0.0.1:${toString config.services.hermes-webui.port}";}];
    };
  };
in {
  imports = [quadlet-nix.nixosModules.quadlet];

  # Host networking reaches loopback services; published ports did this before.
  networking.firewall.allowedTCPPorts = [80 443];

  virtualisation.podman.enable = true;

  virtualisation.quadlet = {
    autoEscape = true;

    networks.proxy.networkConfig.driver = "bridge";

    volumes.traefik_letsencrypt.volumeConfig = {};

    containers.traefik = {
      unitConfig = {
        After = "podman.socket";
        Requires = "podman.socket";
      };

      containerConfig = {
        name = "traefik";
        image = "docker.io/library/traefik:v3";
        pull = "newer";
        networks = ["host"];

        volumes = [
          "${volumes.traefik_letsencrypt.ref}:/var/lib/traefik/letsencrypt"
          "/var/lib/secrets/cf-dns-api-token:/var/lib/secrets/cf-dns-api-token:ro"
          "/run/podman:/run/podman"
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
          "--providers.docker.endpoint=unix:///run/podman/podman.sock"
          "--providers.docker.exposedByDefault=false"
          "--providers.docker.network=proxy"
          "--providers.docker.watch=true"
          "--providers.file.filename=/etc/traefik/dynamic.yml"
          "--entryPoints.websecure.address=:443"
          "--entryPoints.websecure.asDefault=true"
          "--entryPoints.websecure.http.tls.certResolver=cloudflare"
          "--certificatesResolvers.cloudflare.acme.email=${vars.acmeEmail}"
          "--certificatesResolvers.cloudflare.acme.storage=/var/lib/traefik/letsencrypt/acme.json"
          "--certificatesResolvers.cloudflare.acme.dnsChallenge=true"
          "--certificatesResolvers.cloudflare.acme.dnsChallenge.provider=cloudflare"
          # MagicDNS answers for the tailnet domain; check the challenge publicly.
          "--certificatesResolvers.cloudflare.acme.dnsChallenge.resolvers=1.1.1.1:53,9.9.9.9:53"
          "--serverstransport.insecureSkipVerify=true"
        ];

        labels = {
          "traefik.enable" = "true";
          "traefik.http.routers.api.rule" = "Host(`traefik.${vars.domain}`) && (PathPrefix(`/api`) || PathPrefix(`/dashboard`))";
          "traefik.http.routers.api.service" = "api@internal";
          "traefik.http.services.api.loadBalancer.server.port" = "1";
        };
      };

      serviceConfig = {
        Restart = "always";
        RestartSec = "10";
      };
    };
  };
}

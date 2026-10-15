{
  config,
  osConfig,
  ...
}: let
  inherit (osConfig) vars;
in {
  virtualisation.quadlet = let
    inherit (config.virtualisation.quadlet) networks volumes;
  in {
    networks.proxy.networkConfig.driver = "bridge";

    volumes.traefik_letsencrypt.volumeConfig = {};

    containers.traefik = {
      unitConfig = {
        After = "podman.socket";
        Requires = "podman.socket";
        RequiresMountsFor = "/var/lib/podman";
      };
      containerConfig = {
        name = "traefik";
        image = "docker.io/library/traefik:v3";
        pull = "newer";
        networks = [networks.proxy.ref];
        publishPorts = ["80:80" "443:443"];
        volumes = [
          "${volumes.traefik_letsencrypt.ref}:/var/lib/traefik/letsencrypt"
          "/var/lib/secrets/cf-dns-api-token:/var/lib/secrets/cf-dns-api-token:ro"
          "%t/podman:/run/podman"
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
          "--entryPoints.websecure.address=:443"
          "--entryPoints.websecure.asDefault=true"
          "--entryPoints.websecure.http.tls.certResolver=cloudflare"
          "--certificatesResolvers.cloudflare.acme.email=${vars.acmeEmail}"
          "--certificatesResolvers.cloudflare.acme.storage=/var/lib/traefik/letsencrypt/acme.json"
          "--certificatesResolvers.cloudflare.acme.dnsChallenge=true"
          "--certificatesResolvers.cloudflare.acme.dnsChallenge.provider=cloudflare"
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

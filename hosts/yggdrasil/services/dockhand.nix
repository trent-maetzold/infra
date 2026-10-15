{
  config,
  osConfig,
  ...
}: let
  inherit (osConfig) vars;
in {
  virtualisation.quadlet = let
    inherit (config.virtualisation.quadlet) networks pods volumes;
  in {
    volumes = {
      dockhand_data.volumeConfig = {};
      dockhand_pgdata.volumeConfig = {};
    };

    pods.dockhand_pod = {
      unitConfig = {
        After = "podman.socket";
        Requires = "podman.socket";
        RequiresMountsFor = "/var/lib/podman";
      };
      podConfig = {
        networks = [networks.proxy.ref];
      };
    };

    containers.dockhand = {
      containerConfig = {
        name = "dockhand";
        image = "docker.io/fnsys/dockhand:latest";
        pull = "newer";
        pod = pods.dockhand_pod.ref;
        environmentFiles = ["/var/lib/secrets/dockhand-env"];
        volumes = [
          "${volumes.dockhand_data.ref}:/var/lib/dockhand"
          "%t/podman/podman.sock:/var/run/docker.sock"
        ];
        environments = {
          TZ = "America/Chicago";
          DATA_DIR = "/var/lib/dockhand";
        };
        labels = {
          "traefik.enable" = "true";
          "traefik.http.routers.dockhand.rule" = "Host(`dockhand.${vars.domain}`)";
          "traefik.http.services.dockhand.loadBalancer.server.port" = "3000";
        };
      };
      serviceConfig = {
        Restart = "always";
        RestartSec = "10";
      };
    };

    containers.dockhand_db = {
      containerConfig = {
        name = "dockhand_db";
        image = "docker.io/library/postgres:18";
        pull = "newer";
        pod = pods.dockhand_pod.ref;
        environmentFiles = ["/var/lib/secrets/dockhand-env"];
        volumes = ["${volumes.dockhand_pgdata.ref}:/var/lib/postgresql"];
        environments = {
          TZ = "America/Chicago";
          POSTGRES_USER = "dockhand";
          POSTGRES_DB = "dockhand";
        };
        healthCmd = "pg_isready -U dockhand -d dockhand";
        healthInterval = "30s";
        healthRetries = 5;
        healthStartPeriod = "30s";
        healthTimeout = "5s";
      };
      serviceConfig = {
        Restart = "always";
        RestartSec = "10";
      };
    };
  };
}

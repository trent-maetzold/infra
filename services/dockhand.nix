# Dockhand on yggdrasil, public behind traefik.
{config, ...}: let
  endpoint = {
    host = "127.0.0.1";
    port = 3000;
  };

  nixos = {
    config,
    quadlet-nix,
    ...
  }: let
    inherit (config.virtualisation.quadlet) pods volumes;
  in {
    imports = [quadlet-nix.nixosModules.quadlet];

    virtualisation.podman.enable = true;

    virtualisation.quadlet = {
      autoEscape = true;

      volumes = {
        dockhand_data.volumeConfig = {};
        dockhand_pgdata.volumeConfig = {};
      };

      pods.dockhand_pod = {
        unitConfig = {
          After = "podman.socket";
          Requires = "podman.socket";
        };

        podConfig.publishPorts = ["${endpoint.host}:${toString endpoint.port}:3000"];
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
            "/run/podman/podman.sock:/var/run/docker.sock"
          ];

          environments = {
            TZ = "America/Chicago";
            DATA_DIR = "/var/lib/dockhand";
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
  };
in {
  my.endpoints.dockhand = endpoint;

  my.services.dockhand = {
    host = "yggdrasil";
    modules = [nixos];
    routes.dockhand = config.flake.lib.makePublicRoute endpoint;
  };
}

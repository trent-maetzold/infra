# Honcho memory server: rootful pod of API, deriver, PostgreSQL (pgvector) and
# Valkey sharing the pod's localhost; only the API is published. The secret
# /var/lib/secrets/honcho-db-password holds the database password.
{quadlet-nix, ...}: let
  honcho = {
    image = "ghcr.io/plastic-labs/honcho:v3.3.0";
    pod = "honcho.pod";
    secrets = ["honcho-db-password,type=env,target=PGPASSWORD"];

    environments = {
      DB_CONNECTION_URI = "postgresql+psycopg://honcho@127.0.0.1:5432/honcho";
      CACHE_URL = "redis://127.0.0.1:6379/0?suppress=true";
      CACHE_ENABLED = "true";
    };
  };

  nixos = {config, ...}: {
    imports = [quadlet-nix.nixosModules.quadlet];

    persist.dirs."/var/lib/honcho/postgres" = {
      mode = "0700";
      snapshots = true;

      zfs = {
        recordsize = "16K";
        logbias = "throughput";
        atime = "off";
      };
    };

    systemd.tmpfiles.rules = ["d /var/lib/honcho/postgres 0700 root root -"];

    virtualisation.podman.enable = true;

    virtualisation.quadlet = {
      pods.honcho = {
        # Podman hands the secret to the containers as env.
        serviceConfig.ExecStartPre = "${config.virtualisation.podman.package}/bin/podman secret create --replace honcho-db-password /var/lib/secrets/honcho-db-password";
        # Netavark's DNAT skips the host firewall, so bind where it may be reached.
        podConfig.publishPorts = ["127.0.0.1:8000:8000"];
      };

      containers = {
        honcho-db.containerConfig = {
          image = "docker.io/pgvector/pgvector:0.8.1-pg18";
          inherit (honcho) pod;
          secrets = ["honcho-db-password,type=env,target=POSTGRES_PASSWORD"];
          volumes = ["/var/lib/honcho/postgres:/var/lib/postgresql"];

          environments = {
            POSTGRES_USER = "honcho";
            POSTGRES_DB = "honcho";
          };
        };

        # A cache: no snapshots.
        honcho-cache.containerConfig = {
          image = "docker.io/valkey/valkey:8";
          inherit (honcho) pod;
          exec = "valkey-server --save ''";
        };

        # Restarts until the database accepts connections.
        honcho-api = {
          containerConfig = honcho // {exec = "sh docker/entrypoint.sh";};
          serviceConfig.Restart = "always";
        };

        honcho-deriver = {
          containerConfig = honcho // {exec = "/app/.venv/bin/python -m src.deriver";};
          serviceConfig.Restart = "always";
        };
      };
    };
  };
in {
  my.services.honcho.nixos = nixos;
}

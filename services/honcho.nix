# Honcho memory server: API, deriver, PostgreSQL (pgvector) and Valkey on the
# `honcho` network, reaching each other by container name; only the API is
# published, on the host's loopback. The secret
# /var/lib/secrets/honcho-db-password holds the database password.
{quadlet-nix, ...}: let
  nixos = {config, ...}: let
    inherit (config.virtualisation.quadlet) networks volumes;

    # Podman hands the secret to the containers as env.
    secret = {
      ExecStartPre = "${config.virtualisation.podman.package}/bin/podman secret create --replace honcho-db-password /var/lib/secrets/honcho-db-password";
      Restart = "always";
    };

    container = name: {
      inherit name;
      networks = [networks.honcho.ref];
    };

    honcho =
      container "honcho-api"
      // {
        image = "ghcr.io/plastic-labs/honcho:latest";
        secrets = ["honcho-db-password,type=env,target=PGPASSWORD"];

        environments = {
          DB_CONNECTION_URI = "postgresql+psycopg://honcho@honcho-db:5432/honcho";
          CACHE_URL = "redis://honcho-cache:6379/0?suppress=true";
          CACHE_ENABLED = "true";
        };
      };
  in {
    imports = [quadlet-nix.nixosModules.quadlet];

    # Volumes, not the image store.
    persist.dirs."/var/lib/containers/storage/volumes".snapshots = true;

    virtualisation.podman.enable = true;

    virtualisation.quadlet = {
      networks.honcho = {};
      volumes.honcho_pgdata = {};

      containers = {
        honcho-db = {
          serviceConfig = secret;

          containerConfig =
            container "honcho-db"
            // {
              image = "docker.io/pgvector/pgvector:pg18";
              secrets = ["honcho-db-password,type=env,target=POSTGRES_PASSWORD"];
              volumes = ["${volumes.honcho_pgdata.ref}:/var/lib/postgresql"];

              environments = {
                POSTGRES_USER = "honcho";
                POSTGRES_DB = "honcho";
              };
            };
        };

        # A cache: no snapshots.
        honcho-cache.containerConfig =
          container "honcho-cache"
          // {
            image = "docker.io/valkey/valkey:9";
            exec = "valkey-server --save ''";
          };

        # Restarts until the database accepts connections. Podman's DNAT
        # skips the host firewall, so publish on loopback only.
        honcho-api = {
          serviceConfig = secret;

          containerConfig =
            honcho
            // {
              exec = "sh docker/entrypoint.sh";
              publishPorts = ["127.0.0.1:8000:8000"];
            };
        };

        honcho-deriver = {
          serviceConfig = secret;
          containerConfig = honcho // container "honcho-deriver" // {exec = "/app/.venv/bin/python -m src.deriver";};
        };
      };
    };
  };
in {
  my.services.honcho.nixos = nixos;
}

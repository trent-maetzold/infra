# Honcho memory server: API (port 8000, tailnet) and deriver containers on host
# networking, using this host's PostgreSQL and Valkey. The secret
# /var/lib/secrets/honcho-env holds PGPASSWORD for the honcho role and Honcho's
# LLM_* keys.
{quadlet-nix, ...}: let
  honcho = {
    env = "/var/lib/secrets/honcho-env";

    container = {
      image = "ghcr.io/plastic-labs/honcho:v3.3.0";
      networks = ["host"];
      environmentFiles = [honcho.env];

      environments = {
        DB_CONNECTION_URI = "postgresql+psycopg://honcho@127.0.0.1:5432/honcho";
        CACHE_URL = "redis://127.0.0.1:6379/0?suppress=true";
        CACHE_ENABLED = "true";
      };
    };

    unit = rec {
      After = ["postgresql-setup.service" "redis-honcho.service"];
      Requires = After;
    };
  };

  nixos = {
    imports = [quadlet-nix.nixosModules.quadlet];

    networking.firewall.extraInputRules = ''
      ip saddr 100.64.0.0/10 tcp dport 8000 accept
    '';

    services = {
      postgresql = {
        enable = true;
        ensureDatabases = ["honcho"];

        ensureUsers = [
          {
            name = "honcho";
            ensureDBOwnership = true;
          }
        ];
      };

      redis.servers.honcho = {
        enable = true;
        port = 6379;
      };
    };

    # Password from the secret; pgvector needs a superuser to create
    systemd.services.postgresql-setup = {
      serviceConfig.EnvironmentFile = honcho.env;

      postStart = ''
        psql -v pw="$PGPASSWORD" <<< "ALTER ROLE honcho PASSWORD :'pw'"
        psql -d honcho -c "CREATE EXTENSION IF NOT EXISTS vector"
      '';
    };

    virtualisation.quadlet.containers = {
      honcho-api = {
        unitConfig = honcho.unit;
        containerConfig = honcho.container // {exec = "sh docker/entrypoint.sh";};
      };

      honcho-deriver = {
        unitConfig = honcho.unit;
        containerConfig = honcho.container // {exec = "/app/.venv/bin/python -m src.deriver";};
      };
    };
  };
in {
  # Features
  features.nixos.services.honcho = nixos;
}

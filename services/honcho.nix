# Honcho memory server: API (port 8000, tailnet) and deriver containers on host
# networking, using this host's PostgreSQL and Valkey. The secret
# /var/lib/secrets/honcho-db-password holds only the honcho role's password.
{
  config,
  quadlet-nix,
  ...
}: let
  inherit (config.my) services;

  honcho = {
    password = "/var/lib/secrets/honcho-db-password";

    container = {
      image = "ghcr.io/plastic-labs/honcho:v3.3.0";
      networks = ["host"];
      secrets = ["honcho-db-password,type=env,target=PGPASSWORD"];

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

  nixos = {config, ...}: {
    imports = [
      services.postgres.nixos
      services.redis.nixos
      quadlet-nix.nixosModules.quadlet
    ];

    networking.firewall.extraInputRules = ''
      ip saddr ${config.vars.tailnet.subnet} tcp dport 8000 accept
    '';

    services = {
      postgresql = {
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

    # ensureClauses.password only takes a literal hash; pgvector needs a superuser to create
    systemd.services.postgresql-setup.postStart = ''
      psql -v pw="$(< ${honcho.password})" <<< "ALTER ROLE honcho PASSWORD :'pw'"
      psql -d honcho -c "CREATE EXTENSION IF NOT EXISTS vector"
    '';

    virtualisation.quadlet.containers = let
      # Podman hands the secret to the containers as PGPASSWORD.
      serviceConfig.ExecStartPre = "${config.virtualisation.podman.package}/bin/podman secret create --replace honcho-db-password ${honcho.password}";
    in {
      honcho-api = {
        inherit serviceConfig;
        unitConfig = honcho.unit;
        containerConfig = honcho.container // {exec = "sh docker/entrypoint.sh";};
      };

      honcho-deriver = {
        inherit serviceConfig;
        unitConfig = honcho.unit;
        containerConfig = honcho.container // {exec = "/app/.venv/bin/python -m src.deriver";};
      };
    };
  };
in {
  my.services.honcho = {
    inherit nixos;
    vars.url = "http://yggdrasil.ts.trkm.io:8000";
  };
}

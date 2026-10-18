# Honcho memory server: API (port 8000, tailnet) and deriver containers in one
# rootless pod on the host network, using PostgreSQL and Valkey in the `data`
# container; the host firewall decides who reaches 8000. The secret
# /var/lib/secrets/honcho-db-password holds only the honcho role's password.
{config, ...}: let
  inherit (config) features;
  inherit (config.my) services;

  honcho = {
    password = "/var/lib/secrets/honcho-db-password";

    container = {
      image = "ghcr.io/plastic-labs/honcho:v3.3.0";
      pod = "honcho.pod";
      secrets = ["honcho-db-password,type=env,target=PGPASSWORD"];

      environments = {
        DB_CONNECTION_URI = "postgresql+psycopg://honcho@127.0.0.1:5432/honcho";
        CACHE_URL = "redis://127.0.0.1:6379/0?suppress=true";
        CACHE_ENABLED = "true";
      };
    };
  };

  nixos = {config, ...}: {
    imports = [services.postgres.nixos services.redis.nixos];

    networking.firewall.extraInputRules = ''
      ip saddr ${config.vars.tailnet.subnet} tcp dport 8000 accept
    '';

    containers.data = {
      bindMounts.${honcho.password} = {};

      config.services = {
        postgresql = {
          extensions = ps: [ps.pgvector];
          ensureDatabases = ["honcho"];

          ensureUsers = [
            {
              name = "honcho";
              ensureDBOwnership = true;
            }
          ];

          ensurePasswords.honcho = honcho.password;
          ensureExtensions.honcho = ["vector"];
        };

        # A cache: no snapshots.
        redis.servers.honcho = {
          enable = true;
          port = 6379;
          save = [];
        };
      };
    };

    # Rootless as `honcho`.
    home-manager.users.honcho = {
      imports = [features.home.containers.quadlet];

      home = {
        username = "honcho";
        homeDirectory = "/var/lib/honcho";
      };

      virtualisation.quadlet = {
        pods.honcho = {
          # Podman hands the secret to the containers as PGPASSWORD.
          serviceConfig.ExecStartPre = "${config.virtualisation.podman.package}/bin/podman secret create --replace honcho-db-password ${honcho.password}";

          podConfig.networks = ["host"];
        };

        containers = {
          honcho-api.containerConfig = honcho.container // {exec = "sh docker/entrypoint.sh";};
          honcho-deriver.containerConfig = honcho.container // {exec = "/app/.venv/bin/python -m src.deriver";};
        };
      };
    };

    users = {
      groups.honcho = {};

      users.honcho = {
        isSystemUser = true;
        group = "honcho";
        home = "/var/lib/honcho";
        createHome = true;
        linger = true;
        autoSubUidGidRange = true;
      };
    };

    virtualisation.podman.enable = true;
  };
in {
  my.services.honcho.nixos = nixos;
}

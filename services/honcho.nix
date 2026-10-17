# Honcho memory server: API (port 8000, tailnet) and deriver containers in one
# pod, using PostgreSQL and Valkey in the `data` container. The pod runs on
# pasta, which forwards its localhost 5432/6379 to the host's and publishes 8000 as a host
# socket, so the host firewall decides who reaches it. The secret
# /var/lib/secrets/honcho-db-password holds only the honcho role's password.
{config, ...}: let
  inherit (config) features;
  inherit (config.my) services;

  # Points Hermes at this Honcho wherever it is imported: the host and its
  # home-manager users. Without Honcho, Hermes keeps its built-in memory.
  hermes = {
    lib,
    options,
    ...
  }: {
    config = lib.mkMerge [
      (lib.optionalAttrs (options ? services.hermes-agent) {
        services.hermes-agent = {
          environment.HONCHO_BASE_URL = "http://127.0.0.1:8000";

          settings.memory = {
            provider = "honcho";
            write_approval = true;
          };
        };
      })
      (lib.optionalAttrs (options ? home-manager) {home-manager.sharedModules = [hermes];})
    ];
  };

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
    imports = [
      hermes
      services.postgres.nixos
      services.redis.nixos
      features.nixos.containers.quadlet
    ];

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

    virtualisation.quadlet = let
      inherit (config.virtualisation.quadlet) pods;
    in {
      pods.honcho = {
        unitConfig = rec {
          After = ["container@data.service"];
          Requires = After;
        };

        # Podman hands the secret to the containers as PGPASSWORD.
        serviceConfig.ExecStartPre = "${config.virtualisation.podman.package}/bin/podman secret create --replace honcho-db-password ${honcho.password}";

        podConfig = {
          networks = ["pasta:-T,5432,-T,6379"];
          publishPorts = ["8000:8000"];
        };
      };

      containers = {
        honcho-api.containerConfig = honcho.container // {exec = "sh docker/entrypoint.sh";};
        honcho-deriver.containerConfig = honcho.container // {exec = "/app/.venv/bin/python -m src.deriver";};
      };
    };
  };
in {
  my.services.honcho.nixos = nixos;
}

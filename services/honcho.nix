# Honcho memory server: API (port 8000, tailnet) and deriver containers in one
# pod, using this host's PostgreSQL and Valkey. The pod runs on pasta, which
# forwards its localhost 5432/6379 to the host's and publishes 8000 as a host
# socket, so the host firewall decides who reaches it. The secret
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
    imports = [
      services.postgres.nixos
      services.redis.nixos
      features.nixos.containers.quadlet
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

        ensurePasswords.honcho = honcho.password;
        ensureExtensions.honcho = ["vector"];
      };

      redis.servers.honcho = {
        enable = true;
        port = 6379;
      };
    };

    virtualisation.quadlet = let
      inherit (config.virtualisation.quadlet) pods;
    in {
      pods.honcho = {
        unitConfig = rec {
          After = ["postgresql-setup.service" "redis-honcho.service"];
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
  my.services.honcho = {
    inherit nixos;
    vars.url = "http://yggdrasil.ts.trkm.io:8000";
  };
}

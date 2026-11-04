# Kaneo's bundled web/API container and a private PostgreSQL database.
{
  config,
  quadlet-nix,
  ...
}: let
  inherit (config.flake.lib) makeEnvFile makeServiceRoute;
  port = 5173;
  modules.nixos = {
    config,
    lib,
    pkgs,
    kaneo-db-password,
    kaneo-auth-secret,
    ...
  }: let
    inherit (config.virtualisation.quadlet) networks volumes;
    database = makeEnvFile {
      inherit pkgs;
      name = "kaneo-db";
      vars.POSTGRES_PASSWORD = kaneo-db-password;
    };
    application = makeEnvFile {
      inherit pkgs;
      name = "kaneo";
      vars = {
        POSTGRES_PASSWORD = kaneo-db-password;
        AUTH_SECRET = kaneo-auth-secret;
      };
    };
  in {
    imports = [quadlet-nix.nixosModules.quadlet];
    virtualisation.podman.enable = true;

    virtualisation.quadlet = {
      networks.kaneo = {};
      volumes.kaneo-db = {};
      containers = {
        kaneo-db = {
          serviceConfig = {
            inherit (database) ExecStartPre;
            Restart = "always";
          };
          containerConfig = {
            name = "kaneo-db";
            image = lib.mkDefault "docker.io/library/postgres:16-alpine";
            networks = [networks.kaneo.ref];
            volumes = ["${volumes.kaneo-db.ref}:/var/lib/postgresql/data"];
            environmentFiles = [database.file];
            environments = {
              POSTGRES_USER = "kaneo";
              POSTGRES_DB = "kaneo";
            };
          };
        };
        kaneo = {
          unitConfig = {
            BindsTo = ["kaneo-db.service"];
            Requires = ["kaneo-db.service"];
            After = ["kaneo-db.service"];
          };
          serviceConfig = {
            inherit (application) ExecStartPre;
            Restart = "always";
            # Start order is not readiness: the API exits until Postgres accepts
            # connections, so back off instead of hammering the database.
            RestartSec = "5s";
          };
          containerConfig = {
            name = "kaneo";
            image = lib.mkDefault "ghcr.io/usekaneo/kaneo:2.49.0";
            networks = [networks.kaneo.ref];
            environmentFiles = [application.file];
            publishPorts = lib.mkDefault ["127.0.0.1:${toString port}:${toString port}"];
            environments = {
              POSTGRES_HOST = "kaneo-db";
              POSTGRES_USER = "kaneo";
              POSTGRES_DB = "kaneo";
              KANEO_CLIENT_URL = lib.mkDefault "http://localhost:${toString port}";
            };
          };
        };
      };
    };
  };

  route = makeServiceRoute {
    hostname = "kan.ts.trkm.io";
    ip = config.hosts.yggdrasil.ips.tailnet;
    inherit port;
  };

  hosts.yggdrasil = {config, ...}: {
    sops.secrets = {
      kaneo-db-password.key = "kaneo/db-password";
      kaneo-auth-secret.key = "kaneo/auth-secret";
    };
    _module.args = {
      kaneo-db-password = config.sops.secrets.kaneo-db-password.path;
      kaneo-auth-secret = config.sops.secrets.kaneo-auth-secret.path;
    };
    persistence.dirs."/var/lib/containers/storage/volumes".snapshots = true;
    virtualisation.quadlet.containers.kaneo.containerConfig = {
      publishPorts = ["${route.endpoint.ip}:${toString port}:${toString port}"];
      environments.KANEO_CLIENT_URL = "https://${route.hostname}";
    };
  };
in {
  # Flake Modules
  flake.modules.nixos.kaneo = modules.nixos;

  # NixOS Configuration Modules
  flake.nixosModules.yggdrasil.imports = [
    config.flake.modules.nixos.kaneo
    config.flake.modules.nixos.quadlet
    hosts.yggdrasil
  ];

  # Home Configuration Modules
  flake.homeModules.tm.programs.mcp.servers.kaneo.url = "https://${route.hostname}/api/mcp";

  # Routes
  routes.kaneo = route;
}

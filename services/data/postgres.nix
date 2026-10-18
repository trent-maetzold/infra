# PostgreSQL 18 in the `data` container, reachable over the tailnet with
# passwords; features needing a database import it.
# Adds `ensurePasswords` and `ensureExtensions`, applied by postgresql-setup on
# every start.
{config, ...}: let
  inherit (config.my) services;

  postgres = {
    config,
    lib,
    pkgs,
    ...
  }: let
    inherit (config.services.postgresql) ensureExtensions ensurePasswords;
    setPasswords = lib.mapAttrsToList (role: _: ''psql -v pw="$(< "$CREDENTIALS_DIRECTORY/${role}")" <<< "ALTER ROLE \"${role}\" PASSWORD :'pw'"'') ensurePasswords;
    createExtensions = lib.concatLists (lib.mapAttrsToList (db: map (ext: ''psql -d "${db}" -c 'CREATE EXTENSION IF NOT EXISTS "${ext}"' '')) ensureExtensions);
  in {
    options.services.postgresql = {
      ensurePasswords = lib.mkOption {
        type = lib.types.attrsOf lib.types.str;
        default = {};
        description = "Role → file holding its password; ensureClauses.password only takes a literal hash.";
      };

      ensureExtensions = lib.mkOption {
        type = lib.types.attrsOf (lib.types.listOf lib.types.str);
        default = {};
        description = "Database → extensions to create, which needs the superuser.";
      };
    };

    config = {
      services.postgresql = {
        enable = true;
        package = pkgs.postgresql_18;
        enableTCPIP = true;

        authentication = ''
          local all postgres peer
          local all all scram-sha-256
          host all all 127.0.0.1/32 scram-sha-256
          host all all ::1/128 scram-sha-256
          host all all ${config.vars.tailnet.subnet} scram-sha-256
        '';
      };

      # Credentials, since the files are rarely readable by postgres.
      systemd.services.postgresql-setup = {
        postStart = lib.concatLines (setPasswords ++ createExtensions);
        serviceConfig.LoadCredential = lib.mapAttrsToList (role: file: "${role}:${file}") ensurePasswords;
      };
    };
  };

  nixos = {config, ...}: {
    imports = [services.data.nixos];

    networking.firewall.extraInputRules = ''
      ip saddr ${config.vars.tailnet.subnet} tcp dport 5432 accept
    '';

    containers.data = {
      bindMounts."/var/lib/postgresql".isReadOnly = false;
      config.imports = [postgres];
    };

    # Records near PostgreSQL's 8K page.
    persist.dirs."/var/lib/postgresql" = {
      snapshots = true;
      user = "postgres";
      group = "postgres";
      mode = "0750";

      zfs = {
        atime = "off";
        logbias = "throughput";
        recordsize = "16K";
      };
    };

    systemd.services."container@data".unitConfig.RequiresMountsFor = ["/var/lib/postgresql"];
  };
in {
  my.services.postgres.nixos = nixos;
}

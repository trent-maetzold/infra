# PostgreSQL 18 with pgvector, reachable over the tailnet with passwords;
# features needing a database import it. Adds `ensurePasswords` and
# `ensureExtensions`, applied by postgresql-setup on every start.
let
  postgres = {
    config,
    lib,
    pkgs,
    ...
  }: let
    inherit (config.services.postgresql) ensureExtensions ensurePasswords;
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
      networking.firewall.extraInputRules = ''
        ip saddr ${config.vars.tailnet.subnet} tcp dport 5432 accept
      '';

      services.postgresql = {
        enable = true;
        package = pkgs.postgresql_18;
        extensions = ps: [ps.pgvector];
        enableTCPIP = true;

        authentication = ''
          local all postgres peer
          local all all scram-sha-256
          host all all 127.0.0.1/32 scram-sha-256
          host all all ::1/128 scram-sha-256
          host all all ${config.vars.tailnet.subnet} scram-sha-256
        '';
      };

      systemd.services.postgresql-setup.postStart = lib.concatLines (
        lib.mapAttrsToList (role: file: ''psql -v pw="$(< ${file})" <<< "ALTER ROLE \"${role}\" PASSWORD :'pw'"'') ensurePasswords
        ++ lib.concatLists (lib.mapAttrsToList (db: map (ext: ''psql -d "${db}" -c 'CREATE EXTENSION IF NOT EXISTS "${ext}"' '')) ensureExtensions)
      );
    };
  };
in {
  my.services.postgres.nixos = postgres;
}

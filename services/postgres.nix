# PostgreSQL 18 with pgvector, reachable over the tailnet with passwords;
# features needing a database import it.
let
  postgres = {pkgs, ...}: {
    networking.firewall.extraInputRules = ''
      ip saddr 100.64.0.0/10 tcp dport 5432 accept
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
        host all all 100.64.0.0/10 scram-sha-256
      '';
    };
  };
in {
  # Features
  features.nixos.services.postgres = postgres;
}

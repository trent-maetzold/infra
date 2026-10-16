{pkgs, ...}: {
  networking.firewall.extraInputRules = ''
    ip saddr 100.64.0.0/10 tcp dport 5432 accept
  '';

  services.postgresql = {
    enable = true;
    package = pkgs.postgresql_18;
    extensions = ps: [ps.pgvector];
    enableTCPIP = true;

    authentication = ''
      local all all peer
      host all all 127.0.0.1/32 scram-sha-256
      host all all ::1/128 scram-sha-256
      host all all 100.64.0.0/10 scram-sha-256
    '';
  };
}

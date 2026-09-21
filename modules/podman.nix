{lib, ...}: {
  virtualisation.containers.containersConf.settings = {
    network = {
      # Rootless pasta must publish IPv4-only: with IPv6 in play the port relay
      # binds an address the host (or WSL) cannot reach.
      pasta_options = lib.mkAfter ["--ipv4-only"];
    };
  };
}

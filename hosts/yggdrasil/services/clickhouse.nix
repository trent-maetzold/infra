{config, ...}: {
  networking.firewall.extraInputRules = ''
    ip saddr ${config.vars.tailnet.subnet} tcp dport { 8123, 9000 } accept
  '';

  services.clickhouse = {
    enable = true;
    serverConfig.listen_host = "::";
  };

  systemd.services.clickhouse.unitConfig.RequiresMountsFor = "/var/lib/clickhouse";
}

{config, ...}: {
  networking.firewall.extraInputRules = ''
    ip saddr ${config.vars.tailnet.subnet} tcp dport { 8123, 9000 } accept
  '';

  containers.data = {
    bindMounts."/var/lib/clickhouse".isReadOnly = false;

    config.services.clickhouse = {
      enable = true;
      serverConfig.listen_host = "::";
    };
  };

  systemd.services."container@data".unitConfig.RequiresMountsFor = "/var/lib/clickhouse";
}

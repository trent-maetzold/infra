# ClickHouse, and tuning for the `data` container's databases on ZFS datasets.
{config, ...}: {
  networking.firewall.extraInputRules = ''
    ip saddr ${config.vars.tailnet.subnet} tcp dport { 8123, 9000 } accept
  '';

  containers.data = {
    bindMounts."/var/lib/clickhouse".isReadOnly = false;

    config.services = {
      clickhouse = {
        enable = true;
        serverConfig.listen_host = "::";
      };

      # ZFS never tears a record, so full-page images only bloat the WAL.
      postgresql.settings.full_page_writes = false;
    };
  };

  systemd.services."container@data".unitConfig.RequiresMountsFor = ["/var/lib/clickhouse" "/var/lib/postgresql"];
}

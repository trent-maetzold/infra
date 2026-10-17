# ClickHouse, and tuning for the `data` container's databases on ZFS datasets.
{config, ...}: {
  # disko-zfs creates new datasets and sets properties on switch.
  disko.devices.zpool.tank.datasets = {
    # ClickHouse compresses its own parts: lz4 skips them cheaply.
    clickhouse = {
      type = "zfs_fs";
      mountpoint = "/var/lib/clickhouse";

      options = {
        atime = "off";
        compression = "lz4";
        mountpoint = "legacy";
      };
    };

    # Records near PostgreSQL's 8K page; ZFS covers torn pages and the WAL.
    postgresql = {
      type = "zfs_fs";
      mountpoint = "/var/lib/postgresql";

      options = {
        atime = "off";
        logbias = "throughput";
        mountpoint = "legacy";
        recordsize = "16K";
      };
    };
  };

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

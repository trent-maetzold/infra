# ClickHouse in the `data` container, reachable over the tailnet, on its own
# `tank` dataset.
{config, ...}: let
  inherit (config.my) services;

  nixos = {config, ...}: {
    imports = [services.data.nixos];

    # ClickHouse compresses its own parts: lz4 skips them cheaply.
    disko.devices.zpool.tank.datasets.clickhouse = {
      type = "zfs_fs";
      mountpoint = "/var/lib/clickhouse";

      options = {
        atime = "off";
        compression = "lz4";
        mountpoint = "legacy";
      };
    };

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

    systemd.services."container@data".unitConfig.RequiresMountsFor = ["/var/lib/clickhouse"];
  };
in {
  my.services.clickhouse.nixos = nixos;
}

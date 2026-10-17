# ClickHouse in the `data` container, reachable over the tailnet.
{config, ...}: let
  inherit (config.my) services;

  nixos = {
    config,
    lib,
    options,
    ...
  }: {
    imports = [services.data.nixos];

    config = lib.mkMerge [
      {
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
      }

      # Disko hosts get a `tank` dataset; ClickHouse compresses its own parts,
      # so lz4 skips them cheaply.
      (lib.optionalAttrs (options ? disko) {
        disko.devices.zpool.tank.datasets.clickhouse = {
          type = "zfs_fs";
          mountpoint = "/var/lib/clickhouse";

          options = {
            atime = "off";
            compression = "lz4";
            mountpoint = "legacy";
          };
        };
      })
    ];
  };
in {
  my.services.clickhouse.nixos = nixos;
}

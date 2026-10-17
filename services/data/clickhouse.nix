# ClickHouse in the `data` container, reachable over the tailnet.
{config, ...}: let
  inherit (config.my) services;

  nixos = {config, ...}: {
    imports = [services.data.nixos];

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

    persist.dirs."/var/lib/clickhouse" = {
      atime = "off";
      compression = "lz4";
    };

    systemd.services."container@data".unitConfig.RequiresMountsFor = ["/var/lib/clickhouse"];
  };
in {
  my.services.clickhouse.nixos = nixos;
}

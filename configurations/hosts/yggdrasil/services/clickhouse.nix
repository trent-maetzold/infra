{config, ...}: let
  out = _: {
    networking.firewall.extraInputRules = ''
      ip saddr 100.64.0.0/10 tcp dport { 8123, 9000 } accept
    '';

    services.clickhouse = {
      enable = true;
      serverConfig.listen_host = "::";
    };

    systemd.services.clickhouse.unitConfig.RequiresMountsFor = "/var/lib/clickhouse";
  };
in {
  # Features
  features.nixos.yggdrasil.clickhouse = out;

  # NixOS Modules
  flake.nixosModules.yggdrasil.imports = [config.features.nixos.yggdrasil.clickhouse];
}

# NixOS container `data` on nixpkgs-stable, sharing the host network, so the
# databases inside only change when that input is bumped. Services add
# themselves through `containers.data.config` and bind their state from the
# host (ZFS datasets mount there); the host firewall guards their ports.
{
  config,
  nixpkgs-stable,
  ...
}: let
  inherit (config) features vars;

  nixos = {
    config,
    lib,
    ...
  }: {
    # Postgres, Valkey and ClickHouse each import this; the key dedups it.
    key = "asgard#services.data";

    containers.data = {
      autoStart = true;
      nixpkgs = nixpkgs-stable;

      config = {
        # 26.11 stateVersion from global on 26.05 nixpkgs is fine: it only pins defaults.
        imports = [features.nixos.base.vars vars.global];
        # The host's unstable platform attrset recurses in stable's nixpkgs module.
        nixpkgs.hostPlatform = lib.mkForce config.nixpkgs.hostPlatform.system;
        # Shared netns: its firewall would replace the host's ruleset.
        networking.firewall.enable = false;
      };
    };
  };
in {
  my.services.data.nixos = nixos;
}

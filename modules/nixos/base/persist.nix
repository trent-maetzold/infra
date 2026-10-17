# Paths whose state outlives a rebuild. Features declare them; the host maps
# them onto its persistence method (yggdrasil: ZFS datasets).
{config, ...}: let
  persist = {lib, ...}: {
    options.persist = {
      dirs = lib.mkOption {
        type = lib.types.attrsOf (lib.types.attrsOf lib.types.str);
        default = {};
        description = "Directory → backend hints, e.g. ZFS properties.";
      };

      files = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [];
      };
    };
  };
in {
  features.nixos.base.persist = persist;
  flake.nixosModules.default.imports = [config.features.nixos.base.persist];
}

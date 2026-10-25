# State that outlives a reboot. Features declare what they need; the host
# picks how: `volumes` for dirs wanting snapshots, `plain` for the rest. On a
# persistent root (`none`) there is nothing to do.
{
  config,
  lib,
  ...
}: let
  makeSnapshotWarnings = import ./_lib/make-snapshot-warnings.nix {inherit lib;};
in let
  persist = {
    config,
    lib,
    ...
  }: let
    inherit (lib) mkOption types;

    owner = {
      user = mkOption {
        type = types.str;
        default = "root";
      };

      group = mkOption {
        type = types.str;
        default = "root";
      };

      mode = mkOption {
        type = types.str;
        default = "0755";
      };
    };

    hints = mkOption {
      type = types.attrsOf types.str;
      default = {};
    };
  in {
    options.persist = {
      volumes = mkOption {
        type = types.enum ["none" "zfs" "btrfs"];
        default = "none";
      };

      plain = mkOption {
        type = types.enum ["none" "impermanence" "preservation"];
        default = "none";
      };

      dirs = mkOption {
        default = {};

        type = types.attrsOf (types.submodule {
          options =
            owner
            // {
              # Its own dataset/subvolume, snapshotted independently.
              snapshots = mkOption {
                type = types.bool;
                default = false;
              };

              zfs = hints;
              btrfs = hints;
            };
        });
      };

      files = mkOption {
        type = types.attrsOf (types.submodule {options = owner;});
        default = {};
      };
    };

    config.warnings = makeSnapshotWarnings config.persist;
  };
in {
  flake.modules.nixos.persist = persist;
  flake.nixosModules.default.imports = [config.flake.modules.nixos.persist];
}

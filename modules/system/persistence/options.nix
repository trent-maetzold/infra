# `persistence`: what state features need kept, and how the host keeps it.
{
  flake.modules.nixos.persistence = {lib, ...}: let
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
    options.persistence = {
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
  };
}

# Disk `main`: a 4G ESP and btrfs @nix, @persist and @home.
# Hosts set `disko.devices.disk.main.device`.
{
  config,
  disko,
  ...
}: let
  mountOptions = ["compress=zstd" "noatime"];

  modules.nixos = {
    imports = [disko.nixosModules.disko];

    disko.devices.disk.main = {
      type = "disk";

      content = {
        type = "gpt";

        partitions = {
          esp = {
            size = "4G";
            type = "EF00";

            content = {
              type = "filesystem";
              format = "vfat";
              mountpoint = "/boot";
              mountOptions = ["fmask=0077" "dmask=0077"];
            };
          };

          root = {
            size = "100%";

            content = {
              type = "btrfs";
              extraArgs = ["-f"];

              subvolumes = {
                "@nix" = {
                  mountpoint = "/nix";
                  inherit mountOptions;
                };

                "@persist" = {
                  mountpoint = "/persist";
                  inherit mountOptions;
                };

                "@home" = {
                  mountpoint = "/home";
                  inherit mountOptions;
                };
              };
            };
          };
        };
      };
    };
  };
in {
  # Flake Modules
  flake.modules.nixos.disko-btrfs = modules.nixos;

  # NixOS Configuration Modules
  flake.nixosModules.frigg.imports = [config.flake.modules.nixos.disko-btrfs];
  flake.nixosModules.thor.imports = [config.flake.modules.nixos.disko-btrfs];
}

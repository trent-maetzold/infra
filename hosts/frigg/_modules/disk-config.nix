# One NVMe: an ESP and btrfs for /nix, /persist and /home; `/` is a tmpfs.
{disko, ...}: let
  mountOptions = ["compress=zstd" "noatime"];
in {
  imports = [disko.nixosModules.disko];

  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
  };

  fileSystems."/persist".neededForBoot = true;

  disko.devices = {
    nodev."/" = {
      fsType = "tmpfs";
      mountOptions = ["size=2G" "mode=755"];
    };

    disk.nvme0 = {
      type = "disk";
      device = "/dev/nvme0n1";

      content = {
        type = "gpt";

        partitions = {
          esp = {
            size = "1G";
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
}

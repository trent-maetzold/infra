{
  disko,
  disko-zfs,
  ...
}: let
  makeDisk = {
    n,
    serial,
  }: {
    type = "disk";
    device = "/dev/disk/by-id/nvme-Samsung_SSD_970_EVO_Plus_2TB_${serial}";
    content = {
      type = "gpt";
      partitions = {
        esp = {
          size = "1G";
          type = "EF00";
          label = "esp${toString n}";
          content = {
            type = "filesystem";
            format = "vfat";
            mountpoint =
              if n == 0
              then "/boot/efi"
              else null;
            mountOptions = ["fmask=0077" "dmask=0077"];
          };
        };
        zfs = {
          size = "100%";
          content = {
            type = "zfs";
            pool = "tank";
          };
        };
      };
    };
  };
in {
  imports = [disko.nixosModules.disko disko-zfs.nixosModules.default];

  disko = {
    zfs = {
      enable = true;
      settings.ignoredDatasets = ["tank/unraid-cache"];
    };
    devices = {
      disk = {
        nvme0 = makeDisk {
          n = 0;
          serial = "S59CNM0W619880X";
        };
        nvme1 = makeDisk {
          n = 1;
          serial = "S59CNM0W538791D";
        };
        nvme2 = makeDisk {
          n = 2;
          serial = "S59CNM0W518854F";
        };
        nvme3 = makeDisk {
          n = 3;
          serial = "S59CNM0W518856Z";
        };
        nvme4 = makeDisk {
          n = 4;
          serial = "S59CNM0W619589N";
        };
        nvme5 = makeDisk {
          n = 5;
          serial = "S59CNM0W619882P";
        };
        nvme6 = makeDisk {
          n = 6;
          serial = "S59CNM0W619751J";
        };
      };
      zpool = {
        tank = {
          type = "zpool";
          mode = "raidz2";
          options = {
            ashift = "12";
            autoexpand = "on";
          };
          rootFsOptions = {
            compression = "zstd";
            xattr = "sa";
            acltype = "posixacl";
            recordsize = "1M";
            mountpoint = "none";
          };
          datasets = {
            root = {
              type = "zfs_fs";
              mountpoint = "/";
              options.mountpoint = "legacy";
            };
            boot = {
              type = "zfs_fs";
              mountpoint = "/boot";
              options.mountpoint = "legacy";
            };
            podman = {
              type = "zfs_fs";
              mountpoint = "/var/lib/podman";
              options.mountpoint = "legacy";
            };
            clickhouse = {
              type = "zfs_fs";
              mountpoint = "/var/lib/clickhouse";
              options.mountpoint = "legacy";
            };
            postgresql = {
              type = "zfs_fs";
              mountpoint = "/var/lib/postgresql";
              options.mountpoint = "legacy";
            };
            redis = {
              type = "zfs_fs";
              mountpoint = "/var/lib/redis";
              options.mountpoint = "legacy";
            };
            "unraid-cache" = {
              type = "zfs_volume";
              size = "7T";
              options = {
                volblocksize = "64K";
                compression = "zstd";
              };
            };
          };
        };
      };
    };
  };
}

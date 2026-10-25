# Snapshotted dirs get their own `tank` dataset; the rest live on the
# persistent root.
{
  config,
  lib,
  ...
}: {
  persistence.volumes = "zfs";

  disko.devices.zpool.tank.datasets = lib.mapAttrs' (dir: d:
    lib.nameValuePair (baseNameOf dir) {
      type = "zfs_fs";
      mountpoint = dir;
      options = {mountpoint = "legacy";} // d.zfs;
      # A switch can add a dataset; mount it only once disko-zfs created it.
      mountOptions = ["x-systemd.requires=disko-zfs.service"];
    })
  (lib.filterAttrs (_: d: d.snapshots) config.persistence.dirs);
}

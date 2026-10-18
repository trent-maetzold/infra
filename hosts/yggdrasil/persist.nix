# Snapshotted dirs get their own `tank` dataset; the rest live on the
# persistent root.
{
  config,
  lib,
  ...
}: {
  persist.volumes = "zfs";

  disko.devices.zpool.tank.datasets = lib.mapAttrs' (dir: d:
    lib.nameValuePair (baseNameOf dir) {
      type = "zfs_fs";
      mountpoint = dir;
      options = {mountpoint = "legacy";} // d.zfs;
    })
  (lib.filterAttrs (_: d: d.snapshots) config.persist.dirs);
}

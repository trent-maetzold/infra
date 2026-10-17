# Each persisted directory gets its own `tank` dataset; files already live on
# the persistent root.
{
  config,
  lib,
  ...
}: {
  disko.devices.zpool.tank.datasets = lib.mapAttrs' (dir: options:
    lib.nameValuePair (baseNameOf dir) {
      type = "zfs_fs";
      mountpoint = dir;
      options = {mountpoint = "legacy";} // options;
    })
  config.persist.dirs;

  # ZFS never tears a record, so full-page images only bloat the WAL.
  containers.data.config.services.postgresql.settings.full_page_writes = false;
}

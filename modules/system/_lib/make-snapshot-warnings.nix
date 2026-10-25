# Warnings for persist dirs wanting snapshots on a host without volumes.
{lib}: persist: let
  snapshotted = lib.attrNames (lib.filterAttrs (_: d: d.snapshots) persist.dirs);
in
  lib.optional (persist.volumes == "none" && snapshotted != []) "persist: ${lib.concatStringsSep ", " snapshotted} want snapshots, but persist.volumes is none."

# Warnings for persistence dirs wanting snapshots on a host without volumes.
{lib}: persistence: let
  snapshotted = lib.attrNames (lib.filterAttrs (_: d: d.snapshots) persistence.dirs);
in
  lib.optional (persistence.volumes == "none" && snapshotted != []) "persistence: ${lib.concatStringsSep ", " snapshotted} want snapshots, but persistence.volumes is none."

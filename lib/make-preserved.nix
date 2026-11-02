# Preservation entries from `persistence` dirs or files; `key` is "directory" or "file".
{lib, ...}: {
  flake.helpers.makePreserved = key: entries:
    lib.mapAttrsToList (path: o: {
      ${key} = path;
      inherit (o) user group mode;
    })
    entries;
}

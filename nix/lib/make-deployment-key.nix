# identityFile is a runtime string; only the encrypted source enters the store.
{
  secretFile,
  identityFile,
  destDir,
  user ? "root",
  group ? "root",
}:
assert builtins.isString identityFile; {
  keyCommand = ["age" "--decrypt" "--identity" identityFile "${secretFile}"];
  inherit destDir user group;
}

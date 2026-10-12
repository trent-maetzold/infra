# A colmena deployment key (used by colmena nodes in configurations/).
#
# The deployer decrypts the age file with the controller's ssh key and pipes the
# plaintext into destDir on the target at apply time, so the host never holds a
# private key. `secretFile` is the repo path; interpolating it copies the file to
# the store, which keeps keyCommand independent of the deployer's cwd.
#
# `user`/`group` name the owner of the decrypted file on the target. A service
# that does not run as root must be named here — root-owned 0600 is unreadable to
# the podman user, and the failure only shows up as an empty secret at runtime.
{
  secretFile,
  destDir,
  user ? "root",
  group ? "root",
}: {
  keyCommand = [
    "sh"
    "-c"
    ''age -d -i "$HOME/.ssh/id_ed25519" ${secretFile}''
  ];
  inherit destDir user group;
}

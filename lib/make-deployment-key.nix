# A colmena deployment key, declared under `deployment.keys` of makeHost.
#
# The deployer decrypts `secret` (an age file path on the deploying machine, so
# the flake never needs the secrets as an input) with the controller's ssh key
# and pipes the plaintext into destDir on the target at apply time, so the host
# never holds a private key.
#
# `user`/`group` name the owner of the decrypted file on the target. A service
# that does not run as root must be named here — root-owned 0600 is unreadable to
# the podman user, and the failure only shows up as an empty secret at runtime.
{lib, ...}: {
  flake.lib.makeDeploymentKey = {
    secret,
    destDir ? "/run/keys",
    user ? "root",
    group ? "root",
  }: {
    keyCommand = ["sh" "-c" ''age -d -i "$HOME/.ssh/id_ed25519" ${lib.escapeShellArg secret}''];
    inherit destDir user group;
  };
}

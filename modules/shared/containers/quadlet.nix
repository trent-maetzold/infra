# quadlet-nix: Podman containers, pods and networks as systemd units; features
# running containers import it.
{quadlet-nix, ...}: {
  # Features
  features = {
    home.containers.quadlet = quadlet-nix.homeManagerModules.quadlet;
    nixos.containers.quadlet = quadlet-nix.nixosModules.quadlet;
  };
}

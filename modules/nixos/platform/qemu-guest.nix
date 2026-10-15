{config, ...}: let
  out = {modulesPath, ...}: {
    imports = ["${modulesPath}/profiles/qemu-guest.nix"];
  };
in {
  # Features
  features.nixos.platform.qemu-guest = out;

  # NixOS Modules
  flake.nixosModules.qemu-guest.imports = [config.features.nixos.platform.qemu-guest];
}

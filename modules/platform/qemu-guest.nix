{config, ...}: let
  out = {modulesPath, ...}: {
    imports = ["${modulesPath}/profiles/qemu-guest.nix"];
  };
in {
  # Modules
  my.modules.platform.qemu-guest.nixos = out;

  # NixOS Modules
  flake.nixosModules.qemu-guest.imports = [config.my.modules.platform.qemu-guest.nixos];
}

{config, ...}: let
  out = {
    boot = {
      loader = {
        systemd-boot.enable = true;
        efi.efiSysMountPoint = "/boot/efi";
      };
      zfs.forceImportRoot = true;
    };
  };
in {
  # Features
  features.nixos.yggdrasil.boot = out;

  # NixOS Modules
  flake.nixosModules.yggdrasil.imports = [config.features.nixos.yggdrasil.boot];
}

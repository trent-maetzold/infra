{config, ...}: let
  out = {
    fileSystems = {
      "/" = {
        device = "/dev/disk/by-label/nixos";
        fsType = "ext4";
        autoResize = true;
      };
      "/boot" = {
        device = "/dev/disk/by-label/ESP";
        fsType = "vfat";
      };
    };

    virtualisation.diskSize = 24 * 1024;
  };
in {
  # Features
  features.nixos.heimdall.disk-config = out;

  # NixOS Modules
  flake.nixosModules.heimdall.imports = [config.features.nixos.heimdall.disk-config];
}

{config, ...}: let
  out = {
    boot = {
      loader = {
        systemd-boot = {
          enable = true;
          configurationLimit = 3;
        };
        efi.canTouchEfiVariables = false;
      };
      growPartition = true;
      kernelParams = ["net.ifnames=0"];
    };
  };
in {
  # Features
  features.nixos.heimdall.boot = out;

  # NixOS Modules
  flake.nixosModules.heimdall.imports = [config.features.nixos.heimdall.boot];
}

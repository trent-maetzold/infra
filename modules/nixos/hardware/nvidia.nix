{config, ...}: let
  out = {
    hardware.nvidia-container-toolkit.enable = true;
    nixpkgs.config.allowUnfreePackages = ["nvidia-container-toolkit"];
  };
in {
  # Features
  features.nixos.hardware.nvidia = out;

  # NixOS Modules
  flake.nixosModules.nvidia.imports = [config.features.nixos.hardware.nvidia];
}

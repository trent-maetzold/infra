{config, ...}: let
  out = {
    hardware.nvidia-container-toolkit.enable = true;
    nixpkgs.config.allowUnfreePackages = ["nvidia-container-toolkit"];
  };
in {
  # Modules
  my.modules.hardware.nvidia.nixos = out;

  # NixOS Modules
  flake.nixosModules.nvidia.imports = [config.my.modules.hardware.nvidia.nixos];
}

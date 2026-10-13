{config, ...}: {
  flake.nixos.hardware.nvidia = {
    hardware.nvidia-container-toolkit.enable = true;
    nixpkgs.config.allowUnfreePackages = ["nvidia-container-toolkit"];
  };
  flake.nixosModules.nvidia.imports = [config.flake.nixos.hardware.nvidia];
}

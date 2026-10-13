{config, ...}: {
  flake.modules.nixos.nvidia = {
    hardware.nvidia-container-toolkit.enable = true;
    nixpkgs.config.allowUnfreePackages = ["nvidia-container-toolkit"];
  };
  flake.nixosModules.nvidia.imports = [config.flake.modules.nixos.nvidia];
}

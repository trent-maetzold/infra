{config, ...}: {
  flake.nixosModules.nvidia = {
    config,
    lib,
    ...
  }: let
    cfg = config.hardware.nvidia-container-toolkit;
  in {
    config = lib.mkIf cfg.enable {
      nixpkgs.config.allowUnfreePackages = ["nvidia-container-toolkit"];
    };
  };
  flake.nixosModules.default.imports = [config.flake.nixosModules.nvidia];
}

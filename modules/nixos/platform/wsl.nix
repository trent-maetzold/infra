{
  config,
  nixos-wsl,
  ...
}: let
  inherit (config) flake;
in {
  flake.nixos.platform.wsl = {
    config,
    lib,
    pkgs,
    ...
  }: {
    imports = [nixos-wsl.nixosModules.wsl flake.nixos.packages.wsl];

    hardware = lib.mkIf config.hardware.nvidia-container-toolkit.enable {
      nvidia-container-toolkit.suppressNvidiaDriverAssertion = true;
      nvidia.package = pkgs.runCommand "wsl-nvidia-driver-stub" {outputs = ["out" "lib"];} "mkdir -p $out $lib";
    };

    wsl = {
      enable = true;
      startMenuLaunchers = true;
      useWindowsDriver = true;
    };
  };
  flake.nixosModules.wsl.imports = [config.flake.nixos.platform.wsl];
}

# NixOS on WSL, using the Windows GPU driver and opening links in Windows.
{
  config,
  nixos-wsl,
  ...
}: let
  modules.nixos = {
    config,
    lib,
    pkgs,
    ...
  }: {
    imports = [nixos-wsl.nixosModules.wsl];

    environment.systemPackages = with pkgs; [
      (writeShellScriptBin "wslview" ''exec wsl-open "$@"'')
      wsl-open
    ];

    hardware = lib.mkIf config.hardware.nvidia-container-toolkit.enable {
      nvidia-container-toolkit.suppressNvidiaDriverAssertion = true;
      nvidia.package = pkgs.runCommand "wsl-nvidia-driver-stub" {outputs = ["out" "lib"];} "mkdir -p $out $lib";
    };

    wsl = {
      enable = true;
      # Keeps .exe launching when any binfmt (e.g. aarch64 emulation) is registered.
      interop.register = true;
      startMenuLaunchers = true;
      useWindowsDriver = true;
    };
  };
in {
  # Flake Modules
  flake.modules.nixos.wsl = modules.nixos;

  # NixOS Configuration Modules
  flake.nixosModules.wsl.imports = [config.flake.modules.nixos.wsl];
}

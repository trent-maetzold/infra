{
  config,
  nixos-wsl,
  ...
}: let
  out = {
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
  # Modules
  my.modules.platform.wsl.nixos = out;

  # NixOS Modules
  flake.nixosModules.wsl.imports = [config.my.modules.platform.wsl.nixos];
}

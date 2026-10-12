{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.wsl;
in {
  config = lib.mkIf cfg.enable {
    environment.systemPackages = lib.mkAfter (with pkgs; [
      (writeShellScriptBin "wslview" ''exec wsl-open "$@"'')
      wsl-open
    ]);
    hardware = lib.mkIf config.hardware.nvidia-container-toolkit.enable {
      nvidia-container-toolkit.suppressNvidiaDriverAssertion = lib.mkDefault true;
      nvidia.package = lib.mkDefault (
        pkgs.runCommand "wsl-nvidia-driver-stub"
        {outputs = ["out" "lib"];} "mkdir -p $out $lib"
      );
    };
    wsl = {
      startMenuLaunchers = lib.mkDefault true;
      useWindowsDriver = lib.mkDefault true;
    };
  };
}

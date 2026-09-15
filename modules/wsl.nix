{
  config,
  lib,
  pkgs,
  ...
}: {
  config = lib.mkIf config.wsl.enable {
    nixpkgs.config.allowUnfreePackages = lib.mkDefault ["nvidia-container-toolkit"];
    wsl = lib.mkDefault {
      useWindowsDriver = true;
      startMenuLaunchers = true;
    };
    environment.systemPackages = lib.mkDefault (with pkgs; [
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
  };
}

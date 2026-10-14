{
  flake.nixos.packages.wsl = {pkgs, ...}: {
    environment.systemPackages = with pkgs; [(writeShellScriptBin "wslview" ''exec wsl-open "$@"'') wsl-open];
  };
}

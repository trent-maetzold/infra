# mise, with every user's shims on PATH.
{config, ...}: let
  modules.nixos = {pkgs, ...}: {
    environment = {
      systemPackages = [pkgs.mise];
      extraInit = ''export PATH="$HOME/.local/share/mise/shims:$PATH"'';
    };
  };
in {
  # Flake Modules
  flake.modules.nixos.mise = modules.nixos;

  # NixOS Configuration Modules
  flake.nixosModules.default.imports = [config.flake.modules.nixos.mise];
}

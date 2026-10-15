{config, ...}: let
  out.programs.zsh.enable = true;
in {
  # Features
  features.nixos.base.shell = out;

  # NixOS Modules
  flake.nixosModules.default.imports = [config.features.nixos.base.shell];
}

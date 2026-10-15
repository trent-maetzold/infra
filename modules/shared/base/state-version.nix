{config, ...}: let
  inherit (config.vars) stateVersion;
  home = {home = {inherit stateVersion;};};
in {
  # NixOS Modules
  flake.nixosModules.default.imports = [
    {system = {inherit stateVersion;};}
    {home-manager.sharedModules = [home];}
  ];

  # Home Manager Modules
  flake.homeModules.default.imports = [home];
}

# Deploy and secrets tools: colmena, nixos-anywhere, rage.
{config, ...}: let
  modules.homeManager = {pkgs, ...}: {
    home.packages = with pkgs; [colmena nixos-anywhere rage];
  };
in {
  # Flake Modules
  flake.modules.homeManager.pkgs-infra = modules.homeManager;

  # Home Configuration Modules
  flake.homeModules.infra.imports = [config.flake.modules.homeManager.pkgs-infra];
}

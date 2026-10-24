# Deploy and secrets tools: colmena, nixos-anywhere, rage, ragenix.
{config, ...}: let
  modules.home = {pkgs, ...}: {
    home.packages = with pkgs; [colmena nixos-anywhere rage ragenix];
  };
in {
  # Flake Modules
  flake.modules.homeManager.pkgs-infra = modules.home;

  # Home Configuration Modules
  flake.homeModules.infra.imports = [config.flake.modules.homeManager.pkgs-infra];
}

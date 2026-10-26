# The family desktop: a base host plus the tailnet; desktop features add themselves.
{config, ...}: {
  # Home Configuration Modules
  flake.homeModules.family = {};

  # NixOS Configuration Modules
  flake.nixosModules.family.imports = with config.flake.nixosModules; [default tailnet];
}

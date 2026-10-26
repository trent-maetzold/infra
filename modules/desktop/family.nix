# The family desktop and the kids' home profile; features add themselves.
{config, ...}: {
  # Home Configuration Modules
  flake.homeModules.kids = {};

  # NixOS Configuration Modules
  flake.nixosModules.family.imports = with config.flake.nixosModules; [default];
}

{
  config,
  quadlet-nix,
  ...
}: let
  out = {lib, ...}: {
    imports = [quadlet-nix.nixosModules.quadlet];

    # quadlet-nix has no global default; give every container one.
    options.virtualisation.quadlet.containers = lib.mkOption {
      type = lib.types.attrsOf (lib.types.submodule {containerConfig.autoUpdate = lib.mkDefault "registry";});
    };

    config.virtualisation.quadlet.autoUpdate.enable = true;
  };
in {
  # Features
  features.nixos.containers.quadlet = out;

  # NixOS Modules
  flake.nixosModules.quadlet.imports = [config.features.nixos.containers.quadlet];
}

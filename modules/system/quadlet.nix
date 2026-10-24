# Podman quadlet containers, auto-updated from their registry, on the host's
# time zone.
{
  config,
  quadlet-nix,
  ...
}: let
  modules.nixos = {lib, ...}: {
    imports = [quadlet-nix.nixosModules.quadlet];

    # quadlet-nix has no global defaults; give every container them.
    options.virtualisation.quadlet.containers = lib.mkOption {
      type = lib.types.attrsOf (lib.types.submodule {
        containerConfig = {
          autoUpdate = lib.mkDefault "registry";
          timezone = lib.mkDefault "local";
        };
      });
    };

    config.virtualisation.quadlet.autoUpdate.enable = true;
  };
in {
  # Flake Modules
  flake.modules.nixos.quadlet = modules.nixos;

  # NixOS Configuration Modules
  flake.nixosModules.quadlet.imports = [config.flake.modules.nixos.quadlet];
}

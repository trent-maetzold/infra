{config, ...}: let
  # Builds heimdall's aarch64 closures locally.
  out.boot.binfmt.emulatedSystems = ["aarch64-linux"];
in {
  # Features
  features.nixos.muninn.binfmt = out;

  # NixOS Modules
  flake.nixosModules.muninn.imports = [config.features.nixos.muninn.binfmt];
}

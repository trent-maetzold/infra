# asgard's lib: flake.nix's helpers, one file each. `specialArgs` is the flake's
# inputs, so `lib.<helper>` is all flake.nix needs to reach.
{
  nixpkgs,
  inputs,
  nixosModules,
  homeManagerModules,
  overlays,
}: let
  inherit (nixpkgs) lib;

  specialArgs = inputs;

  # Modules get evaluated standalone (options docs, downstream probes), so a
  # config that doesn't satisfy every dependency still has to evaluate.
  noCheck = import ./no-check.nix;
in {
  forAllSystems = import ./for-all-systems.nix {inherit lib;};
  pkgsFor = import ./pkgs-for.nix {inherit nixpkgs overlays;};
  evalNixos = import ./eval-nixos.nix {
    inherit lib nixpkgs nixosModules specialArgs noCheck;
  };
  evalHomeManager = import ./eval-home-manager.nix {
    inherit lib homeManagerModules specialArgs noCheck;
  };
  optionsDoc = import ./options-doc.nix;
}

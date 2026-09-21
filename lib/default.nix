{
  nixpkgs,
  inputs,
  nixosModules,
  homeManagerModules,
  overlays,
}: let
  inherit (nixpkgs) lib;

  specialArgs = inputs;

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

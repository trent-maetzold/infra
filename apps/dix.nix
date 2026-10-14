{nixpkgs, ...}: {
  perSystem = {system, ...}: {
    apps.dix = {
      type = "app";
      program = nixpkgs.lib.getExe nixpkgs.legacyPackages.${system}.dix;
      meta.description = "Closure diff, pinned to the flake nixpkgs";
    };
  };
}

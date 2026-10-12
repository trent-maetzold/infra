{inputs, ...}: {
  perSystem = {system, ...}: {
    apps.dix = {
      type = "app";
      program = inputs.nixpkgs.lib.getExe inputs.nixpkgs.legacyPackages.${system}.dix;
      meta.description = "Closure diff, pinned to the flake nixpkgs";
    };
  };
}

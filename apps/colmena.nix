{inputs, ...}: {
  perSystem = {system, ...}: {
    apps.colmena = {
      type = "app";
      program = inputs.nixpkgs.lib.getExe inputs.colmena.packages.${system}.colmena;
      meta.description = "The colmena CLI, pinned to the flake input";
    };
  };
}

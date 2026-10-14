{
  colmena,
  nixpkgs,
  ...
}: {
  perSystem = {system, ...}: {
    apps.colmena = {
      type = "app";
      program = nixpkgs.lib.getExe colmena.packages.${system}.colmena;
      meta.description = "The colmena CLI, pinned to the flake input";
    };
  };
}

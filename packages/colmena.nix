{colmena, ...}: {
  perSystem = {system, ...}: {
    overlayAttrs.colmena = colmena.packages.${system}.colmena;
  };
}

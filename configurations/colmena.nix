{
  config,
  lib,
  colmena,
  nixpkgs,
  ...
}: {
  # Hosts add nodes here; `colmenaHive` is the output colmena reads.
  options.colmenaNodes = lib.mkOption {
    type = lib.types.lazyAttrsOf lib.types.deferredModule;
    default = {};
  };

  config.flake.colmenaHive = colmena.lib.makeHive ({
      meta = {
        nixpkgs = import nixpkgs {system = "x86_64-linux";};
        nodeNixpkgs.heimdall = import nixpkgs {system = "aarch64-linux";};
      };
    }
    // config.colmenaNodes);
}

{
  config,
  inputs,
  lib,
  ...
}: {
  # Hosts add nodes here; `colmenaHive` is the output colmena reads.
  options.colmenaNodes = lib.mkOption {
    type = lib.types.lazyAttrsOf lib.types.deferredModule;
    default = {};
  };

  config.flake.colmenaHive = inputs.colmena.lib.makeHive ({
      meta = {
        nixpkgs = import inputs.nixpkgs {system = "x86_64-linux";};
        nodeNixpkgs.heimdall = import inputs.nixpkgs {system = "aarch64-linux";};
      };
    }
    // config.colmenaNodes);
}

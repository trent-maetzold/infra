{lib, ...}: let
  features = lib.types.lazyAttrsOf (lib.types.lazyAttrsOf lib.types.deferredModule);
in {
  options = {
    features = {
      home = lib.mkOption {
        type = features;
        default = {};
        description = "home-manager features, `<domain>.<feature>`.";
      };
      nixos = lib.mkOption {
        type = features;
        default = {};
        description = "NixOS features, `<domain>.<feature>`.";
      };
    };
    vars = lib.mkOption {
      type = lib.types.lazyAttrsOf lib.types.anything;
      default = {};
      description = "Infra catalog (names, addresses, identities); features read and format it themselves.";
    };
    colmenaNodes = lib.mkOption {
      type = lib.types.lazyAttrsOf lib.types.deferredModule;
      default = {};
      description = "Colmena nodes; `flake.colmenaHive` is built from them.";
    };
    flake.lib = lib.mkOption {
      type = lib.types.lazyAttrsOf lib.types.raw;
      default = {};
      description = "Helper functions shared across files.";
    };
  };
}

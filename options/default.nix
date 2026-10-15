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
      type = lib.types.lazyAttrsOf lib.types.raw;
      default = {};
      description = "This flake's inventory: `global` module, makeHost results in `hosts`, makeUser results in `users`.";
    };
    flake.lib = lib.mkOption {
      type = lib.types.lazyAttrsOf lib.types.raw;
      default = {};
      description = "Public helper functions.";
    };
  };
}

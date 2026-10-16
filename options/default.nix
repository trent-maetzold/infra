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

    my.services = lib.mkOption {
      type = lib.types.lazyAttrsOf (lib.types.submodule {
        options = {
          nixos = lib.mkOption {
            type = lib.types.deferredModule;
            default = {};
          };

          vars = lib.mkOption {
            type = lib.types.lazyAttrsOf lib.types.raw;
            default = {};
          };
        };
      });
      default = {};
      description = "Services hosts import, `<service>.nixos`, and what clients need from them, `<service>.vars`.";
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

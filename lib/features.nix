{lib, ...}: let
  inherit (lib) mkOption types;
  feature = types.lazyAttrsOf (types.lazyAttrsOf types.deferredModule);
in {
  options.flake = {
    home = mkOption {
      type = types.submodule {
        freeformType = feature;
        options.editor = mkOption {
          type = types.submodule {
            freeformType = types.lazyAttrsOf types.deferredModule;
            options.lang = mkOption {
              type = types.lazyAttrsOf types.deferredModule;
              default = {};
              description = "editor language features, `editor.lang.<feature>`.";
            };
          };
          default = {};
          description = "editor features.";
        };
      };
      default = {};
      description = "home-manager features, `<domain>.<feature>`.";
    };
    lib = mkOption {
      type = types.lazyAttrsOf types.raw;
      default = {};
      description = "Helper functions shared across files.";
    };
    nixos = mkOption {
      type = feature;
      default = {};
      description = "NixOS features, `<domain>.<feature>`.";
    };
  };
}

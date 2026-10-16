{lib, ...}: let
  inherit (lib.types) deferredModule lazyAttrsOf;
in {
  options = {
    my.modules = lib.mkOption {
      type = lazyAttrsOf (lazyAttrsOf (lazyAttrsOf deferredModule));
      default = {};
      description = "Modules by domain, `<domain>.<module>.{home,nixos}`.";
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

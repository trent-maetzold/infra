{lib, ...}: {
  options = {
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

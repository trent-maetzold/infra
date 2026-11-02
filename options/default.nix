{lib, ...}: {
  options = {
    flake = {
      helpers = lib.mkOption {
        type = lib.types.lazyAttrsOf lib.types.raw;
        default = {};
        description = "Functions shared across features, outside `flake.lib`.";
      };

      hosts = lib.mkOption {
        type = lib.types.lazyAttrsOf lib.types.raw;
        default = {};
        description = "makeHost results, by host name.";
      };

      lib = lib.mkOption {
        type = lib.types.lazyAttrsOf lib.types.raw;
        default = {};
        description = "Public helper functions.";
      };

      users = lib.mkOption {
        type = lib.types.lazyAttrsOf lib.types.raw;
        default = {};
        description = "makeUser results, by user name.";
      };
    };
  };
}

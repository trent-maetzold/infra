{lib, ...}: {
  options = {
    vars = lib.mkOption {
      type = lib.types.lazyAttrsOf lib.types.raw;
      default = {};
      description = "This flake's shared data, such as the `globals` module.";
    };

    flake = {
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

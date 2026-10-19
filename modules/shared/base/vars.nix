# Values features need from the consumer (login server, domain, ...); set by the
# consumer, typically through one global module shared by makeHost and makeUser.
{config, ...}: let
  out = {lib, ...}: {
    options.vars = lib.mkOption {
      type = lib.types.lazyAttrsOf lib.types.anything;
      default = {};
    };
  };
in {
  # Features
  features = {
    home.base.vars = out;
    nixos.base.vars = out;
  };

  # Modules
  flake = {
    homeModules = {
      default.imports = [config.features.home.base.vars];
      server.imports = [config.features.home.base.vars];
    };

    nixosModules.default.imports = [config.features.nixos.base.vars];
  };
}

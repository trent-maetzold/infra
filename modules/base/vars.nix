# Values modules need from the consumer (login server, domain, ...); set by the
# consumer, typically through one global module shared by makeHost and makeUser.
{config, ...}: let
  out = {lib, ...}: {
    options.vars = lib.mkOption {
      type = lib.types.lazyAttrsOf lib.types.anything;
      default = {};
    };
  };
in {
  # Modules
  my.modules.base.vars = {
    home = out;
    nixos = out;
  };

  # Profiles
  flake = {
    homeModules.default.imports = [config.my.modules.base.vars.home];
    nixosModules.default.imports = [config.my.modules.base.vars.nixos];
  };
}

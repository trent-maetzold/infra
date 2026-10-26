# Values features need from the consumer (login server, domain, ...); set by the
# consumer, typically through one global module shared by makeHost and makeUser.
{config, ...}: let
  modules.vars = {lib, ...}: {
    options.vars = lib.mkOption {
      type = lib.types.lazyAttrsOf lib.types.anything;
      default = {};
    };
  };
in {
  # Flake Modules
  flake.modules.homeManager.vars = modules.vars;
  flake.modules.nixos.vars = modules.vars;

  # Home Configuration Modules
  flake.homeModules.default.imports = [config.flake.modules.homeManager.vars];
  flake.homeModules.default-slim.imports = [config.flake.modules.homeManager.vars];

  # NixOS Configuration Modules
  flake.nixosModules.default.imports = [config.flake.modules.nixos.vars];
}

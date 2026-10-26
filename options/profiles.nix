# Profile registry: hosts and users pull these by name, so a profile whose
# features were all deleted is empty instead of an eval error. Every host and
# user also gets its own profile, which features add themselves to.
{
  config,
  lib,
  ...
}: {
  flake = {
    homeModules =
      lib.mapAttrs (_: _: {}) config.flake.users
      // {
        default = {};
        default-slim = {};
        desktop = {};
        kids = {};
        infra = {};
      };

    nixosModules =
      lib.mapAttrs (_: _: {}) config.flake.hosts
      // {
        default = {};
        desktop = {};
        nvidia = {};
      };
  };
}

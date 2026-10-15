# The flake's one stateVersion, for NixOS hosts, their home-manager users and
# standalone homes alike. Profiles never set it, so they stay reusable.
{lib, ...}: {
  flake.lib.makeStateVersion = stateVersion: {options, ...}: {
    config =
      if options ? system
      then {
        system = {inherit stateVersion;};
        home-manager.sharedModules = [{home = {inherit stateVersion;};}];
      }
      else {home = {inherit stateVersion;};};
  };
}

{config, ...}: let
  stateVersion = config.flake.lib.makeStateVersion {
    inherit config;
    stateVersion = "26.11";
  };
in {
  inherit (stateVersion) features;
  flake = {inherit (stateVersion.flake) homeModules nixosModules;};
}

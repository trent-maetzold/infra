# The flake's one stateVersion as a feature per side, in each default profile.
{
  flake.lib.makeStateVersion = {
    config,
    stateVersion,
  }: {
    features = {
      home.base.state-version.home = {inherit stateVersion;};
      nixos.base.state-version.system = {inherit stateVersion;};
    };

    flake = {
      homeModules.default.imports = [config.features.home.base.state-version];
      nixosModules.default.imports = [config.features.nixos.base.state-version];
    };
  };
}

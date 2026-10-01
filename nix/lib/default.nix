{inputs}: {
  inherit (inputs.nixpkgs.lib) nixosSystem;
  inherit (inputs.colmena.lib) makeHive;

  makeDeploymentKey = import ./make-deployment-key.nix;

  mkHome = {system, ...} @ args:
    inputs.home-manager.lib.homeManagerConfiguration (builtins.removeAttrs args ["system"]
      // {
        pkgs = args.pkgs or inputs.nixpkgs.legacyPackages.${system};
      });

  optionsDoc = import ./options-doc.nix;
}

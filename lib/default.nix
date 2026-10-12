{
  flake.lib = {
    aggregateModulesTarget = import ./_aggregate-modules-target.nix;
    makeDeploymentKey = import ./_make-deployment-key.nix;
  };
}

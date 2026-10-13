# Returns a pkgs whose `aggregateModules` carries `kernel.target` through.
#
# `aggregateModules` builds a module tree and nixpkgs' aggregator drops
# `target`, but `pkgs.vmTools` reads `kernel.target` to name the bootable image
# in the kernel output and throws without it. disko's image builder hands
# vmTools exactly that aggregate, so the build dies inside vmTools.override
# before the VM ever runs.
#
# Deliberately not an overlay. Patching `system.modulesTree` would move every
# host's closure and initrd for a builder bug; disko reads this pkgs only as
# `imageBuilder.pkgs`, so one VM's tooling changes and nothing else does.
{
  flake.lib.aggregateModulesTarget = pkgs:
    pkgs.extend (_final: prev: {
      aggregateModules = modules: let
        aggregated = prev.aggregateModules modules;
        targets = builtins.filter (target: target != null) (map (module: module.target or null) modules);
      in
        if targets == []
        then aggregated
        else aggregated // {target = builtins.head targets;};
    });
}

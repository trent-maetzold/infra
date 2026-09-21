# Evaluate asgard's NixOS modules standalone — options docs, downstream probes.
{
  lib,
  nixpkgs,
  nixosModules,
  specialArgs,
  noCheck,
}: pkgs:
lib.evalModules {
  modules = [nixosModules.default noCheck];
  specialArgs =
    {
      modulesPath = "${nixpkgs}/nixos/modules";
      inherit pkgs;
    }
    // specialArgs;
}

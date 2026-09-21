# Evaluate asgard's home-manager modules standalone.
{
  lib,
  homeManagerModules,
  specialArgs,
  noCheck,
}: pkgs:
lib.evalModules {
  modules = [homeManagerModules.default noCheck];
  specialArgs = {inherit pkgs;} // specialArgs;
}

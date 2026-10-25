# Roblox Studio, run under Wine by Vinegar.
{
  # Flake Modules
  flake.modules.homeManager.roblox-studio = {pkgs, ...}: {
    home.packages = [pkgs.vinegar];
  };
}

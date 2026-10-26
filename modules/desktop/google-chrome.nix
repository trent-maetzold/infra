# Google Chrome; unfree, so users taking it also list it in `unfreePackages`.
{
  # Flake Modules
  flake.modules.homeManager.google-chrome = {pkgs, ...}: {
    home.packages = [pkgs.google-chrome];
  };
}

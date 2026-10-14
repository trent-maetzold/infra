{
  flake.home.packages.lang-go = {pkgs, ...}: {
    home.packages = with pkgs; [delve go gopls gotools];
  };
}

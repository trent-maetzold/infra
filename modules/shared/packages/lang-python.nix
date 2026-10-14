{
  flake.home.packages.lang-python = {pkgs, ...}: {
    home.packages = with pkgs; [basedpyright python3 python3Packages.debugpy ruff uv];
  };
}

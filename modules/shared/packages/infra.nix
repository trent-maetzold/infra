{
  flake.home.packages.infra = {pkgs, ...}: {
    home.packages = with pkgs; [colmena nixos-anywhere];
  };
}

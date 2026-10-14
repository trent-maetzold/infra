let
  out = {pkgs, ...}: {
    home.packages = with pkgs; [colmena nixos-anywhere];
  };
in {
  # Features
  features.home.packages.infra = out;
}

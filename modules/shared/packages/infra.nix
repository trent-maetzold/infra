{config, ...}: let
  packages = pkgs: with pkgs; [age colmena nixos-anywhere oci-cli opentofu ragenix];
in {
  flake.nixos.packages.infra = {pkgs, ...}: {
    environment.systemPackages = packages pkgs;
  };
  flake.home.packages.infra = {pkgs, ...}: {
    home.packages = packages pkgs;
  };
  flake.nixosModules.default.imports = [config.flake.nixos.packages.infra];
  flake.homeModules.default.imports = [config.flake.home.packages.infra];
}

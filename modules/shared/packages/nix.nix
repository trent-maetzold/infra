{
  flake.nixos.packages.nix = {pkgs, ...}: {
    environment.systemPackages = with pkgs; [deadnix nix-diff nix-init nix-output-monitor nix-tree nix-search-tv nix-update nurl];
  };
  flake.home.packages.nix = {pkgs, ...}: {
    home.packages = with pkgs; [deadnix nix-diff nix-init nix-output-monitor nix-tree nix-update nurl];
  };
}

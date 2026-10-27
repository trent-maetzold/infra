# Oracle Instant Client and libaio for unpatched binaries (nix-ld).
let
  modules.nixos = {pkgs, ...}: {
    nixpkgs.config.allowUnfreePackages = ["oracle-instantclient"];
    programs.nix-ld.libraries = with pkgs; [oracle-instantclient.lib oracle-instantclient.dev libaio];
  };
in {
  # Flake Modules
  flake.modules.nixos.nix-ld-oracle = modules.nixos;
}

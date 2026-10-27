# PostgreSQL's libpq for unpatched binaries (nix-ld).
let
  modules.nixos = {pkgs, ...}: {
    programs.nix-ld.libraries = with pkgs; [libpq libpq.dev];
  };
in {
  # Flake Modules
  flake.modules.nixos.nix-ld-postgres = modules.nixos;
}

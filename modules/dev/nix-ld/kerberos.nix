# Kerberos (MIT krb5) for unpatched binaries (nix-ld).
let
  modules.nixos = {pkgs, ...}: {
    programs.nix-ld.libraries = with pkgs.krb5; [lib dev];
  };
in {
  # Flake Modules
  flake.modules.nixos.nix-ld-kerberos = modules.nixos;
}

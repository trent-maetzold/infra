# Kerberos (MIT krb5) for unpatched binaries (nix-ld).
let
  modules.nixos = {pkgs, ...}: {
    programs.nix-ld.libraries = [
      (pkgs.buildEnv {
        name = "nix-ld-kerberos";
        paths = [pkgs.krb5];
        extraOutputsToInstall = ["lib" "dev"];
      })
    ];
  };
in {
  # Flake Modules
  flake.modules.nixos.nix-ld-kerberos = modules.nixos;
}

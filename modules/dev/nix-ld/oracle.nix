# Oracle Instant Client and libaio for unpatched binaries (nix-ld).
let
  modules.nixos = {pkgs, ...}: {
    nixpkgs.config.allowUnfreePackages = ["oracle-instantclient"];
    programs.nix-ld.libraries = [
      pkgs.libaio
      (pkgs.buildEnv {
        name = "nix-ld-oracle";
        paths = [pkgs.oracle-instantclient];
        extraOutputsToInstall = ["lib" "dev"];
      })
    ];
  };
in {
  # Flake Modules
  flake.modules.nixos.nix-ld-oracle = modules.nixos;
}

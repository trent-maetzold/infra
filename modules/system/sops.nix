# Secrets: sops-nix decrypts `secrets.yaml` files with the host's own age key;
# you edit them with the age master key from Bitwarden.
{config, ...}: let
  modules.nixos = {sops-nix, ...}: {
    imports = [sops-nix.nixosModules.sops];

    sops = {
      age = {
        keyFile = "/var/lib/age/key.txt";
        sshKeyPaths = [];
      };

      gnupg.sshKeyPaths = [];
    };
  };

  modules.homeManager = {pkgs, ...}: {
    home.packages = [pkgs.sops];
    home.sessionVariables.SOPS_AGE_KEY_CMD = "rbw get age-master";
  };
in {
  # Flake Modules
  flake.modules = {
    nixos.sops = modules.nixos;
    homeManager.sops = modules.homeManager;
  };

  # NixOS Configuration Modules
  flake.nixosModules = {
    heimdall.imports = [config.flake.modules.nixos.sops];
    yggdrasil.imports = [config.flake.modules.nixos.sops];
  };

  # Home Configuration Modules
  flake.homeModules.infra.imports = [config.flake.modules.homeManager.sops];
}

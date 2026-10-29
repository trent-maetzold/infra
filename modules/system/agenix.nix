# Secrets: agenix decrypts with the host's SSH key; agenix-rekey rekeys them
# from nix-secrets, whose `agenix` app edits them with the master key.
{config, ...}: let
  modules.nixos = {
    agenix,
    agenix-rekey,
    nix-secrets,
    ageMasterPubkey,
    config,
    lib,
    pkgs,
    ...
  }: {
    imports = [agenix.nixosModules.default agenix-rekey.nixosModules.default];

    age.ageBin = lib.getExe pkgs.rage;

    age.rekey = {
      storageMode = "local";
      localStorageDir = nix-secrets + "/rekeyed/${config.networking.hostName}";
      masterIdentities = [
        {
          identity = "/run/user/1000/age-master";
          pubkey = ageMasterPubkey;
        }
      ];
    };
  };
in {
  # Flake Modules
  flake.modules.nixos.agenix = modules.nixos;

  # NixOS Configuration Modules
  flake.nixosModules = {
    heimdall.imports = [config.flake.modules.nixos.agenix];
    yggdrasil.imports = [config.flake.modules.nixos.agenix];
  };
}

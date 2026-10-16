# Valkey for every `services.redis.servers.<name>` a feature enables.
{config, ...}: let
  redis = {pkgs, ...}: {
    services.redis.package = pkgs.valkey;
  };
in {
  # Features
  features.nixos.services.redis = redis;

  # NixOS Modules
  flake.nixosModules.default.imports = [config.features.nixos.services.redis];
}

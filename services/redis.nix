# Valkey in the `data` container for `services.redis.servers.<name>`; features
# running one import it.
{config, ...}: let
  inherit (config.my) services;

  nixos = {
    imports = [services.data.nixos];
    containers.data.config = {pkgs, ...}: {services.redis.package = pkgs.valkey;};
  };
in {
  my.services.redis.nixos = nixos;
}

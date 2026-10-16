# Valkey for `services.redis.servers.<name>`; features running one import it.
let
  redis = {pkgs, ...}: {
    services.redis.package = pkgs.valkey;
  };
in {
  my.services.redis.nixos = redis;
}

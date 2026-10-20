# Yggdrasil's ingress.
{config, ...}: {
  my.services.traefik = {
    host = "yggdrasil";
    modules = [config.features.nixos.network.traefik];
  };
}

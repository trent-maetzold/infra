# Paseo on yggdrasil, reached through its hosted relay.
{config, ...}: {
  my.services.paseo = {
    host = "yggdrasil";
    modules = [config.features.nixos.ai.paseo];
  };
}

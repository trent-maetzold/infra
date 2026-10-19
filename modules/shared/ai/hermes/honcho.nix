# Hermes memory in a Honcho at `my.endpoints.honcho`.
{config, ...}: let
  honcho.services.hermes-agent = {
    environment.HONCHO_BASE_URL = config.my.endpoints.honcho.url;
    settings.memory.provider = "honcho";
  };
in {
  # Features
  features = {
    home.ai.hermes-honcho = honcho;
    nixos.ai.hermes-honcho = honcho;
  };
}

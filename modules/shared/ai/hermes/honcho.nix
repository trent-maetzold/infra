# Hermes memory in a Honcho on the same host, like `my.services.honcho`.
let
  honcho.services.hermes-agent = {
    environment.HONCHO_BASE_URL = "http://127.0.0.1:8000";
    settings.memory.provider = "honcho";
  };
in {
  # Features
  features = {
    home.ai.hermes-honcho = honcho;
    nixos.ai.hermes-honcho = honcho;
  };
}

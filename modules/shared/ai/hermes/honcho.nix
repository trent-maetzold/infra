# Hermes memory in a Honcho at `my.endpoints.honcho`.
{
  config,
  honcho,
  ...
}: let
  agent = {pkgs, ...}: {
    services.hermes-agent = {
      extraPlugins = [(pkgs.runCommand "honcho" {} "cp -r ${honcho}/hermes-plugin-honcho $out")];
      extraPythonPackages = [pkgs.python3.pkgs.honcho-ai];
      environment.HONCHO_BASE_URL = config.my.endpoints.honcho.url;
      settings.memory.provider = "honcho";
    };
  };
in {
  # Features
  features = {
    home.ai.hermes-honcho = agent;
    nixos.ai.hermes-honcho = agent;
  };
}

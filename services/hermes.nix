# Hermes on yggdrasil; its web UI is reached over the tailnet.
{config, ...}: {
  my.services.hermes = {
    host = "yggdrasil";

    modules = [
      config.features.nixos.ai.hermes
      config.features.nixos.ai.hermes-honcho
      {services.hermes-agent.environmentFiles = ["/var/lib/secrets/opencode-env"];}
    ];

    routes.hermes = config.flake.lib.makeTailnetRoute config.my.endpoints.hermes-webui;
  };
}

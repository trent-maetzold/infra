# OpenHands on yggdrasil, reached over the tailnet.
{config, ...}: {
  my.services.openhands = {
    host = "yggdrasil";
    modules = [config.features.nixos.ai.openhands];
    routes.oh = config.flake.lib.makeTailnetRoute config.my.endpoints.openhands;
  };
}

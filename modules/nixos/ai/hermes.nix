# Hermes Agent in its upstream OCI container on podman, with the `hermes` CLI on
# the host routed into it; hermes-webui (`my.endpoints.hermes-webui`) shares its
# HERMES_HOME.
{
  hermes-agent,
  hermes-webui,
  ...
}: let
  endpoint = {
    host = "127.0.0.1";
    port = 8787;
  };

  nixos = {config, ...}: let
    cfg = config.services.hermes-agent;
  in {
    imports = [hermes-agent.nixosModules.default hermes-webui.nixosModules.default];
    virtualisation.docker.enable = false;

    services = {
      hermes-agent = {
        enable = true;
        addToSystemPackages = true;
        container.enable = true;
        container.backend = "podman";
      };

      hermes-webui = {
        enable = true;
        inherit (endpoint) host port;
        inherit (cfg) user group;
        hermesHome = "${cfg.stateDir}/.hermes";
        stateDir = "${cfg.stateDir}/.hermes-webui";
        agent.package = cfg.package;
      };
    };
  };
in {
  # Features
  features.nixos.ai.hermes = nixos;

  my.endpoints.hermes-webui = endpoint;
}

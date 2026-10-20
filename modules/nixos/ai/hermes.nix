# Hermes Agent in its upstream OCI container on podman, with the `hermes` CLI on
# the host routed into it; hermes-webui (`my.endpoints.hermes-webui`) shares its
# HERMES_HOME. The gateway's API server, when enabled, binds `my.endpoints.hermes-gateway`.
{
  hermes-agent,
  hermes-webui,
  ...
}: let
  endpoint = {
    host = "127.0.0.1";
    port = 8787;
  };

  gateway = {
    host = "127.0.0.1";
    port = 8642;
  };

  nixos = {
    config,
    pkgs,
    ...
  }: let
    cfg = config.services.hermes-agent;
  in {
    imports = [hermes-agent.nixosModules.default hermes-webui.nixosModules.default];
    virtualisation.docker.enable = false;

    services = {
      hermes-agent = {
        enable = true;
        addToSystemPackages = true;
        # Upstream builds report 0.0.0, failing plugins' `requires_hermes`; bump with the input.
        package = hermes-agent.packages.${pkgs.stdenv.hostPlatform.system}.default.override {version = "0.22.2";};

        container = {
          enable = true;
          backend = "podman";
          image = "docker.io/library/ubuntu:24.04";
        };

        environment = {
          API_SERVER_HOST = gateway.host;
          API_SERVER_PORT = toString gateway.port;
        };
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

  my.endpoints = {
    hermes-gateway = gateway;
    hermes-webui = endpoint;
  };
}

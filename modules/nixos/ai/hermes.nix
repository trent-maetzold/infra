# Hermes Agent with its dashboard (`my.endpoints.hermes-dashboard`); hermes-webui
# (`my.endpoints.hermes-webui`) shares its HERMES_HOME. The gateway's API server,
# when enabled, binds `my.endpoints.hermes-gateway`.
{
  config,
  lib,
  hermes-agent,
  hermes-webui,
  ...
}: let
  inherit (config) my;

  nixos = {
    config,
    pkgs,
    ...
  }: let
    cfg = config.services.hermes-agent;
  in {
    imports = [hermes-agent.nixosModules.default hermes-webui.nixosModules.default];

    services = {
      hermes-agent = {
        enable = true;
        addToSystemPackages = true;
        # Upstream builds report 0.0.0, failing plugins' `requires_hermes`; bump with the input.
        package = hermes-agent.packages.${pkgs.stdenv.hostPlatform.system}.default.override {version = "0.22.2";};

        backend = {
          mode = "dashboard";
          inherit (my.endpoints.hermes-dashboard) host port;
        };

        environment = {
          API_SERVER_HOST = my.endpoints.hermes-gateway.host;
          API_SERVER_PORT = toString my.endpoints.hermes-gateway.port;
        };
      };

      hermes-webui = {
        enable = true;
        inherit (my.endpoints.hermes-webui) host port;
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

  my.endpoints =
    lib.mapAttrs (_: port: {
      host = lib.mkDefault "127.0.0.1";
      inherit port;
    }) {
      hermes-dashboard = 9119;
      hermes-gateway = 8642;
      hermes-webui = 8787;
    };
}

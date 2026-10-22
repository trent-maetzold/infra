# Hermes Agent with its dashboard (`my.endpoints.hermes-dashboard`); hermes-webui
# (`my.endpoints.hermes-webui`) shares its HERMES_HOME. The gateway's API server,
# when enabled, binds `my.endpoints.hermes-gateway`. Plugins come from
# `my.hermes.plugins`, one entry per plugin directory.
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

  dashboard = {
    host = "127.0.0.1";
    port = 9119;
  };

  nixos = {
    config,
    lib,
    pkgs,
    ...
  }: let
    cfg = config.services.hermes-agent;

    plugins = config.my.hermes.plugins;

    # A plugin is a directory with plugin.yaml at its root, and `extraPlugins`
    # wants that directory, so pack the subtree.
    pack = name: plugin: pkgs.runCommand name {} "cp -r ${plugin.src} $out";
  in {
    imports = [hermes-agent.nixosModules.default hermes-webui.nixosModules.default];

    options.my.hermes.plugins = lib.mkOption {
      type = lib.types.attrsOf (lib.types.submodule {
        options = {
          src = lib.mkOption {
            type = lib.types.path;
            description = "The plugin's directory.";
          };

          enable = lib.mkOption {
            type = lib.types.bool;
            default = true;
            description = "Whether Hermes loads it; one that is only a provider needs linking, not enabling.";
          };
        };
      });
      default = {};
      description = "Plugins by the name in their plugin.yaml, linked as nix-managed-<name>.";
    };

    config = {
      services = {
        hermes-agent = {
          enable = true;
          addToSystemPackages = true;
          # Upstream builds report 0.0.0, failing plugins' `requires_hermes`; bump with the input.
          package = hermes-agent.packages.${pkgs.stdenv.hostPlatform.system}.default.override {version = "0.22.2";};

          backend = {
            mode = "dashboard";
            inherit (dashboard) host port;
          };

          environment = {
            API_SERVER_HOST = gateway.host;
            API_SERVER_PORT = toString gateway.port;
          };

          extraPlugins = lib.mapAttrsToList pack plugins;

          settings.plugins.enabled = lib.attrNames (lib.filterAttrs (_: plugin: plugin.enable) plugins);
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
  };
in {
  # Features
  features.nixos.ai.hermes = nixos;

  my.endpoints = {
    hermes-dashboard = dashboard;
    hermes-gateway = gateway;
    hermes-webui = endpoint;
  };
}

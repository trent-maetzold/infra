# Hermes Agent with its dashboard; hermes-webui shares its HERMES_HOME. On
# yggdrasil the web UI, dashboard and gateway API listen on its tailnet IP for
# the router.
{
  config,
  lib,
  hermes-agent,
  hermes-webui,
  hermex-push,
  oh-my-hermes,
  ...
}: let
  ports = {
    dashboard = 9119;
    gateway = 8642;
    webui = 8787;
  };

  modules.nixos = {
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
          host = lib.mkDefault "127.0.0.1";
          port = lib.mkDefault ports.dashboard;
        };

        environment = {
          API_SERVER_HOST = lib.mkDefault "127.0.0.1";
          API_SERVER_PORT = lib.mkDefault (toString ports.gateway);
        };
      };

      hermes-webui = {
        enable = true;
        host = lib.mkDefault "127.0.0.1";
        port = lib.mkDefault ports.webui;
        inherit (cfg) user group;
        hermesHome = "${cfg.stateDir}/.hermes";
        stateDir = "${cfg.stateDir}/.hermes-webui";
        agent.package = cfg.package;
      };
    };
  };

  routes =
    lib.mapAttrs (name: port: {
      hostname = "${name}.ts.trkm.io";
      endpoint = {
        ip = config.hosts.yggdrasil.ips.tailnet;
        inherit port;
      };
    }) {
      hermes = ports.webui;
      "dash.hermes" = ports.dashboard;
      "gw.hermes" = ports.gateway;
    };

  user = config.vars.users.tm.name;
  dashboard = "https://${routes."dash.hermes".hostname}";

  hosts.yggdrasil = {pkgs, ...}: let
    # Directory plugins need plugin.yaml at the package root
    plugin = name: src: pkgs.runCommand name {} "cp -r ${src} $out";
  in {
    services.hermes-agent = {
      backend = {
        host = routes."dash.hermes".endpoint.ip;
        inherit (routes."dash.hermes".endpoint) port;
      };

      extraPlugins = [(plugin "omh" "${oh-my-hermes}/src/plugin_bundle/omh") (plugin "hermex-push" "${hermex-push}/plugin")];

      environment = {
        API_SERVER_ENABLED = "true";
        API_SERVER_HOST = routes."gw.hermes".endpoint.ip;
        API_SERVER_PORT = toString routes."gw.hermes".endpoint.port;
        # Hermex's relay; only its developer holds the APNs key, so it can't be self-hosted
        HERMEX_PUSH_RELAY_URL = "https://hermex-relay.hermex-relay.workers.dev";
      };
      environmentFiles = map (f: "/var/lib/secrets/${f}") ["codeberg-env" "deepseek-env" "hermes-api-server-env" "hermes-dashboard-env" "opencode-env"];

      # Non-default config.yaml keys
      settings = {
        approvals.deny = ["git push --force*" "*curl*|*sh*" "*wget*|*sh*"];
        checkpoints.enabled = true;

        dashboard = {
          basic_auth.username = user;
          public_url = dashboard;
        };

        # hermes-webui's dashboard link
        webui.dashboard.url = dashboard;

        memory.write_approval = true;
        plugins.enabled = ["omh" "hermex-push"];
        privacy.redact_pii = true;

        skills = {
          guard_agent_created = true;
          write_approval = true;
        };
      };
    };

    services.hermes-webui = {
      host = routes.hermes.endpoint.ip;
      inherit (routes.hermes.endpoint) port;
    };
  };
in {
  # Flake Modules
  flake.modules.nixos.hermes = modules.nixos;

  # NixOS Configuration Modules
  flake.nixosModules.yggdrasil.imports = [
    config.flake.modules.nixos.hermes
    hosts.yggdrasil
  ];

  # Routes
  inherit routes;
}

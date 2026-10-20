# Hermes on yggdrasil with Honcho memory; its web UI, dashboard and gateway API
# are reached over the tailnet.
{
  config,
  honcho,
  oh-my-hermes,
  ...
}: {
  my.services.hermes = {
    host = "yggdrasil";

    modules = [
      config.features.nixos.ai.hermes
      ({pkgs, ...} @ nixos: let
        # Directory plugins need plugin.yaml at the package root
        plugin = name: src: pkgs.runCommand name {} "cp -r ${src} $out";

        # Its httpx/pydantic come from Hermes' sealed venv
        honcho-ai = nixos.config.services.hermes-agent.package.python.pkgs.buildPythonPackage rec {
          pname = "honcho_ai";
          version = "2.6.0";
          format = "wheel";
          src = pkgs.fetchPypi {
            inherit pname version format;
            dist = "py3";
            python = "py3";
            hash = "sha256-gZzdV3Xsrmn2F7FNYMPqPGrJQEs4IfpQy/C2gaoig88=";
          };
          dontCheckRuntimeDeps = true;
        };

        dashboard = "https://${config.flake.lib.routeHostname nixos.config.vars "dash.hermes" config.my.services.hermes.routes."dash.hermes"}";
      in {
        services.hermes-agent = {
          extraPlugins = [(plugin "honcho" "${honcho}/hermes-plugin-honcho") (plugin "omh" "${oh-my-hermes}/src/plugin_bundle/omh")];
          extraPythonPackages = [honcho-ai];

          environment.API_SERVER_ENABLED = "true";
          environmentFiles = map (f: "/var/lib/secrets/${f}") ["codeberg-env" "deepseek-env" "hermes-api-server-env" "hermes-dashboard-env" "opencode-env"];

          hermesHomeFiles."honcho.json" = builtins.toJSON {
            baseUrl = config.my.endpoints.honcho.url;
            hosts.hermes = {
              enabled = true;
              aiPeer = "hermes";
              peerName = config.vars.users.tm.name;
              workspace = "hermes";
            };
          };

          # Non-default config.yaml keys
          settings = {
            approvals.deny = ["git push --force*" "*curl*|*sh*" "*wget*|*sh*"];
            checkpoints.enabled = true;

            dashboard = {
              basic_auth.username = config.vars.users.tm.name;
              public_url = dashboard;
            };

            # hermes-webui's dashboard link
            webui.dashboard.url = dashboard;

            # extraPlugins are linked as nix-managed-<name>, and providers are found by directory
            memory.provider = "nix-managed-honcho";
            memory.write_approval = true;
            plugins.enabled = ["omh"];
            privacy.redact_pii = true;

            skills = {
              guard_agent_created = true;
              write_approval = true;
            };
          };
        };
      })
    ];

    routes = {
      hermes = config.flake.lib.makeTailnetRoute config.my.endpoints.hermes-webui;

      "dash.hermes" = config.flake.lib.makeTailnetRoute config.my.endpoints.hermes-dashboard;
      "gw.hermes" = config.flake.lib.makeTailnetRoute config.my.endpoints.hermes-gateway;
    };
  };
}

# Hermes on yggdrasil; its web UI, dashboard and gateway API are reached over the
# tailnet. Plugins live in plugins/, each adding itself to `modules`.
{config, ...}: let
  vars = config.vars.global.vars;

  dashboard = "https://${config.flake.lib.routeHostname vars "dash.hermes" config.my.services.hermes.routes."dash.hermes"}";

  nixos = {
    services.hermes-agent = {
      environment.API_SERVER_ENABLED = "true";

      environmentFiles = map (f: "/var/lib/secrets/${f}") [
        "codeberg-env"
        "deepseek-env"
        "hermes-api-server-env"
        "hermes-dashboard-env"
        "opencode-env"
      ];

      settings = {
        approvals.deny = ["git push --force*" "*curl*|*sh*" "*wget*|*sh*"];
        checkpoints.enabled = true;

        dashboard = {
          basic_auth.username = config.vars.users.tm.name;
          public_url = dashboard;
        };

        # hermes-webui's dashboard link
        webui.dashboard.url = dashboard;

        privacy.redact_pii = true;

        skills = {
          guard_agent_created = true;
          write_approval = true;
        };
      };
    };
  };
in {
  my.services.hermes = {
    host = "yggdrasil";
    modules = [config.features.nixos.ai.hermes nixos];

    routes = {
      hermes = config.flake.lib.makeTailnetRoute config.my.endpoints.hermes-webui;

      "dash.hermes" = config.flake.lib.makeTailnetRoute config.my.endpoints.hermes-dashboard;
      "gw.hermes" = config.flake.lib.makeTailnetRoute config.my.endpoints.hermes-gateway;
    };
  };
}

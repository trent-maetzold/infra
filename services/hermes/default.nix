# Hermes on yggdrasil; its web UI, dashboard and gateway API are reached over the
# tailnet. Plugins live in plugins/, each setting `extraPlugins` itself.
{
  config,
  i-have-adhd,
  ...
}: let
  vars = config.vars.global.vars;

  user = config.vars.users.tm.name;

  dashboard = "https://${config.flake.lib.routeHostname vars "dash.hermes" config.my.services.hermes.routes."dash.hermes"}";

  # `config` below is the host's; the flake's is read here, before the shadowing.
  nixos = {config, ...}: {
    services.hermes-agent = {
      environment.API_SERVER_ENABLED = "true";

      # SOUL.md sets the voice; this is the skill that sets the shape.
      hermesHomeFiles."skills/productivity/i-have-adhd/SKILL.md" = "${i-have-adhd}/skills/i-have-adhd/SKILL.md";

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
          basic_auth.username = user;
          public_url = dashboard;
        };

        # hermes-webui's dashboard link
        webui.dashboard.url = dashboard;

        privacy.redact_pii = true;

        # settings merges with recursiveUpdate, so a list has one author: this one,
        # naming every plugin the modules linked.
        plugins.enabled = map (plugin: plugin.name) config.services.hermes-agent.extraPlugins;

        skills = {
          disabled = ["opencode"];
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

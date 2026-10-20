# Hermes on yggdrasil with Honcho memory; its web UI is reached over the tailnet.
{config, ...}: {
  my.services.hermes = {
    host = "yggdrasil";

    modules = [
      config.features.nixos.ai.hermes
      {
        services.hermes-agent = {
          container.hostUsers = ["tm"];
          environmentFiles = ["/var/lib/secrets/codeberg-env" "/var/lib/secrets/deepseek-env" "/var/lib/secrets/opencode-env"];

          # Self-hosted Honcho; the container shares the host network
          hermesHomeFiles."honcho.json" = builtins.toJSON {
            baseUrl = config.my.endpoints.honcho.url;
            hosts.hermes = {
              enabled = true;
              aiPeer = "hermes";
              peerName = config.vars.users.tm.name;
              workspace = "hermes";
            };
          };

          # Non-default config.yaml keys; omh and honcho come from the plugin catalog
          settings = {
            approvals.deny = ["git push --force*" "*curl*|*sh*" "*wget*|*sh*"];
            checkpoints.enabled = true;
            memory.provider = "honcho";
            memory.write_approval = true;
            plugins.enabled = ["omh"];
            privacy.redact_pii = true;

            skills = {
              guard_agent_created = true;
              write_approval = true;
            };
          };
        };
      }
    ];

    routes.hermes = config.flake.lib.makeTailnetRoute config.my.endpoints.hermes-webui;
  };
}

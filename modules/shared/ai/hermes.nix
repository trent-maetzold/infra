# Hermes Agent with the oh-my-hermes plugin, hermes-hud and Honcho memory.
# NixOS: the server. Gateway, dashboard backend and hermes-webui share one
#   HERMES_HOME; both bind to localhost, so reach them over SSH or a proxy.
# Home, import one: `hermes` runs the TUI on local state (set
#   `services.hermes-agent.gateway.enable` for the gateway too); `hermes-remote`
#   runs `hermes` over SSH on `config.vars.hermes`, since the TUI can't attach
#   remotely.
{
  config,
  hermes-agent,
  hermes-webui,
  oh-my-hermes,
  ...
}: let
  inherit (config.my.services) honcho;

  # services.hermes-agent shared by server and home
  agent = {pkgs, ...}: {
    enable = true;
    environment.HONCHO_BASE_URL = honcho.vars.url;
    extraPlugins = [(pkgs.runCommand "omh" {} "cp -r ${oh-my-hermes}/src/plugin_bundle/omh $out")];

    # Non-default config.yaml keys; the rest keeps Hermes defaults
    settings = {
      approvals.deny = ["git push --force*" "*curl*|*sh*" "*wget*|*sh*"];
      checkpoints.enabled = true;

      memory = {
        provider = "honcho";
        write_approval = true;
      };

      privacy.redact_pii = true;

      skills = {
        guard_agent_created = true;
        write_approval = true;
      };
    };
  };

  nixos = args @ {
    config,
    pkgs,
    ...
  }: let
    cfg = config.services.hermes-agent;
  in {
    imports = [hermes-agent.nixosModules.default hermes-webui.nixosModules.default];

    environment.systemPackages = [pkgs.llm-agents.hermes-hud];

    services = {
      hermes-agent =
        agent args
        // {
          addToSystemPackages = true;
          backend.mode = "dashboard";
        };

      hermes-webui = {
        enable = true;
        inherit (cfg) user group;
        hermesHome = "${cfg.stateDir}/.hermes";
        agent.package = cfg.package;
      };
    };
  };

  home = args @ {pkgs, ...}: {
    imports = [hermes-agent.homeManagerModules.default];
    home.packages = [pkgs.llm-agents.hermes-hud];
    programs.hermes-agent.enable = true;
    services.hermes-agent = agent args;
  };

  home-remote = {
    config,
    pkgs,
    ...
  }: {
    home.packages = [(pkgs.writeShellScriptBin "hermes" ''exec ssh -t ${config.vars.hermes} hermes "$@"'')];
  };
in {
  # Features
  features = {
    home.ai = {
      hermes = home;
      hermes-remote = home-remote;
    };

    nixos.ai.hermes = nixos;
  };
}

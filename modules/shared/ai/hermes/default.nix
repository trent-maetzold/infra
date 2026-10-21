# Hermes Agent with the oh-my-hermes plugin: the base, import one side. Each
# runs the agent and a dashboard backend (`my.endpoints.hermes-backend`) with a
# session token in HERMES_HOME, which `hermes-session-token` prints for
# hermes-desktop.
# NixOS: the server; hermes-webui (`my.endpoints.hermes-webui`) shares its
# HERMES_HOME.
# Home: the same agent as user services on $XDG_CONFIG_HOME/hermes.
{
  hermes-agent,
  hermes-webui,
  oh-my-hermes,
  ...
}: let
  backend = {
    host = "127.0.0.1";
    port = 9119;
  };

  webui = {
    host = "127.0.0.1";
    port = 8787;
  };

  # Makes the session token once, readable by the hermes group
  token = pkgs: file:
    pkgs.writeShellScript "hermes-token" ''
      [ -s ${file} ] || (umask 027 && ${pkgs.openssl}/bin/openssl rand -hex 32 > ${file})
    '';

  session = pkgs: file: pkgs.writeShellScriptBin "hermes-session-token" "cat ${file}";

  # services.hermes-agent shared by server and home
  agent = {pkgs, ...}: hermesHome: {
    enable = true;
    extraPlugins = [(pkgs.runCommand "omh" {} "cp -r ${oh-my-hermes}/src/plugin_bundle/omh $out")];

    backend = {
      inherit (backend) host port;
      mode = "dashboard";
      sessionTokenFile = "${hermesHome}/session-token";
    };

    # Non-default config.yaml keys; the rest keeps Hermes defaults
    settings = {
      agent.reasoning_effort = "max";

      model = {
        provider = "opencode-go";
        default = "deepseek-v4.1-flash";
      };

      approvals.deny = ["git push --force*" "*curl*|*sh*" "*wget*|*sh*"];
      checkpoints.enabled = true;

      memory.write_approval = true;

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
    hermesHome = "${cfg.stateDir}/.hermes";
  in {
    imports = [hermes-agent.nixosModules.default hermes-webui.nixosModules.default];
    environment.systemPackages = [(session pkgs cfg.backend.sessionTokenFile)];
    systemd.services.hermes-backend.serviceConfig.ExecStartPre = ["${token pkgs cfg.backend.sessionTokenFile}"];

    services = {
      hermes-agent = agent args hermesHome;

      hermes-webui = {
        enable = true;
        inherit (webui) host port;
        inherit (cfg) user group;
        inherit hermesHome;
        stateDir = "${cfg.stateDir}/.hermes-webui";
        agent.package = cfg.package;
      };
    };
  };

  home = args @ {
    config,
    pkgs,
    ...
  }: let
    cfg = config.services.hermes-agent;
  in {
    imports = [hermes-agent.homeManagerModules.default];
    home.packages = [(session pkgs cfg.backend.sessionTokenFile)];
    services.hermes-agent = agent args cfg.hermesHome // {hermesHome = "${config.xdg.configHome}/hermes";};
    systemd.user.services.hermes-backend.Service.ExecStartPre = ["${token pkgs cfg.backend.sessionTokenFile}"];
  };
in {
  # Features
  features = {
    home.ai.hermes = home;
    nixos.ai.hermes = nixos;
  };

  my.endpoints = {
    hermes-backend = backend;
    hermes-webui = webui;
  };
}

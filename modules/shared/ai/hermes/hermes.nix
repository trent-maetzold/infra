# Hermes Agent with the oh-my-hermes plugin: the base, import one side. Each
# runs the agent and a dashboard backend on 127.0.0.1:9119 with a session token
# in HERMES_HOME, for hermes-desktop and hermes-ssh. Honcho, when imported,
# adds itself as memory.
# NixOS: the server; hermes-webui shares its HERMES_HOME.
# Home: the same agent as user services on ~/.hermes.
{
  hermes-agent,
  hermes-webui,
  oh-my-hermes,
  ...
}: let
  # Makes the session token once, readable by the hermes group
  token = pkgs: file:
    pkgs.writeShellScript "hermes-token" ''
      [ -s ${file} ] || (umask 027 && ${pkgs.openssl}/bin/openssl rand -hex 32 > ${file})
    '';

  # services.hermes-agent shared by server and home
  agent = {pkgs, ...}: hermesHome: {
    enable = true;
    extraPlugins = [(pkgs.runCommand "omh" {} "cp -r ${oh-my-hermes}/src/plugin_bundle/omh $out")];

    backend = {
      mode = "dashboard";
      sessionTokenFile = "${hermesHome}/session-token";
    };

    # Non-default config.yaml keys; the rest keeps Hermes defaults
    settings = {
      approvals.deny = ["git push --force*" "*curl*|*sh*" "*wget*|*sh*"];
      checkpoints.enabled = true;

      # Built-in memory always runs; an imported Honcho adds itself as provider.
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
    systemd.services.hermes-backend.serviceConfig.ExecStartPre = ["${token pkgs cfg.backend.sessionTokenFile}"];

    services = {
      hermes-agent = agent args hermesHome;

      hermes-webui = {
        enable = true;
        inherit (cfg) user group;
        inherit hermesHome;
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
    # Keyed: hermes and hermes-tui both import it
    imports = [
      {
        key = "hermes-agent#home";
        imports = [hermes-agent.homeManagerModules.default];
      }
    ];
    services.hermes-agent = agent args cfg.hermesHome;
    systemd.user.services.hermes-backend.Service.ExecStartPre = ["${token pkgs cfg.backend.sessionTokenFile}"];
  };
in {
  # Features
  features = {
    home.ai.hermes = home;
    nixos.ai.hermes = nixos;
  };
}

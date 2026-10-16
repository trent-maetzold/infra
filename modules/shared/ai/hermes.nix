# Hermes Agent with the oh-my-hermes plugin and hermes-hud.
# NixOS: the server. Gateway, dashboard backend and hermes-webui share one
#   HERMES_HOME; both bind to localhost, so reach them over SSH or a proxy.
# Home: the TUI on local state. Set `services.hermes-agent.gateway.enable` to
#   run the gateway too, or `programs.hermes-agent.remote = "<host>"` to run
#   `hermes` on that server over SSH instead (the TUI can't attach remotely).
{
  config,
  hermes-agent,
  hermes-webui,
  oh-my-hermes,
  ...
}: let
  inherit (config) features;

  # services.hermes-agent shared by server and home
  agent = pkgs: {
    enable = true;
    extraPlugins = [(pkgs.runCommand "omh" {} "cp -r ${oh-my-hermes}/src/plugin_bundle/omh $out")];
  };

  nixos = {
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
        agent pkgs
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

  home = {
    config,
    lib,
    pkgs,
    ...
  }: let
    inherit (config.programs.hermes-agent) remote;
  in {
    imports = [hermes-agent.homeManagerModules.default];

    options.programs.hermes-agent.remote = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = "SSH host running the Hermes server; `hermes` runs there instead of locally.";
    };

    config = lib.mkMerge [
      (lib.mkIf (remote == null) {
        home.packages = [pkgs.llm-agents.hermes-hud];
        programs.hermes-agent.enable = true;
        services.hermes-agent = agent pkgs;
      })
      (lib.mkIf (remote != null) {
        home.packages = [(pkgs.writeShellScriptBin "hermes" ''exec ssh -t ${remote} hermes "$@"'')];
      })
    ];
  };
in {
  # Features
  features = {
    home.ai.hermes = home;
    nixos.ai.hermes = nixos;
  };

  # Home Manager Modules
  flake.homeModules.default.imports = [features.home.ai.hermes];
}

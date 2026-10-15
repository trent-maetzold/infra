{config, ...}: let
  out = {
    config,
    lib,
    pkgs,
    ...
  }: {
    programs.codex = {
      enable = true;
      package = lib.mkDefault pkgs.llm-agents.codex;
      context = config.agents.markdown;
      enableMcpIntegration = true;
      inherit (config.agents) skills;
    };
  };
in {
  # Features
  features.home.ai.codex = out;

  # Home Manager Modules
  flake.homeModules.default.imports = [config.features.home.ai.codex];
}

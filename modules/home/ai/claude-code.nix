{config, ...}: let
  inherit (config) features;
  out = {
    config,
    lib,
    pkgs,
    ...
  }: {
    imports = [features.home.ai.agents features.home.ai.mcp];

    programs.claude-code = {
      enable = true;
      # llm-agents' build is not marked unfree, unlike nixpkgs' claude-code.
      package = lib.mkDefault pkgs.llm-agents.claude-code;
      context = config.agents.markdown;
      enableMcpIntegration = true;
      inherit (config.agents) skills;
    };
  };
in {
  # Features
  features.home.ai.claude-code = out;

  # Home Manager Modules
  flake.homeModules.default.imports = [config.features.home.ai.claude-code];
}

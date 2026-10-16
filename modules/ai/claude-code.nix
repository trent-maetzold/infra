{config, ...}: let
  out = {
    config,
    lib,
    pkgs,
    ...
  }: {
    programs.claude-code = {
      enable = true;
      # llm-agents' build is not marked unfree, unlike nixpkgs' claude-code.
      package = lib.mkDefault pkgs.llm-agents.claude-code;
      context = config.agents.md.text;
      enableMcpIntegration = true;
    };
  };
in {
  # Modules
  my.modules.ai.claude-code.home = out;

  # Home Manager Modules
  flake.homeModules.default.imports = [config.my.modules.ai.claude-code.home];
}

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
    };
  };
in {
  # Features
  features.home.ai.claude-code = out;

  # Home Manager Modules
  flake.homeModules.default.imports = [config.features.home.ai.claude-code];
}

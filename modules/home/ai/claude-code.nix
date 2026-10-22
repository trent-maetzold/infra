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
      # Claude Code rewrites settings.json at runtime; merge instead of a read-only store link.
      mutableSettings = true;
      # No "Co-Authored-By: Claude" trailer on commits, no attribution in PR text.
      settings = {
        attribution = false;
        includeCoAuthoredBy = false;
      };
    };

    agents.md.coding-subagents = [
      "- `claude`: Claude Code. Headless: `claude -p \"<prompt>\" --model <model> --effort <low|medium|high|xhigh|max|ultracode>`."
    ];
  };
in {
  # Features
  features.home.ai.claude-code = out;

  # Home Manager Modules
  flake.homeModules.default.imports = [config.features.home.ai.claude-code];
}

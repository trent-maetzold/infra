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
      context = config.agents.md.text;
      enableMcpIntegration = true;
      # Codex rewrites config.toml at runtime; merge instead of a read-only store link.
      mutableSettings = true;
    };

    agents.md.coding-subagents = [
      "- `codex`: OpenAI Codex CLI. Headless: `codex exec -m <model> -c model_reasoning_effort=\"<low|medium|high|xhigh|max>\" \"<prompt>\"`."
    ];
  };
in {
  # Features
  features.home.ai.codex = out;

  # Home Manager Modules
  flake.homeModules.default.imports = [config.features.home.ai.codex];
}

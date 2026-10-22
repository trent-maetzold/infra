{config, ...}: let
  out = {pkgs, ...}: {
    home.packages = [pkgs.llm-agents.dsh];

    agents.md.coding-subagents = [
      "- `dsh`: DeepSeek's agent harness. Headless: `dsh headless \"<task>\"`; the profile's `agentDefaultModel` picks the model and reasoning is the provider default, so no per-run flag."
    ];
  };
in {
  # Features
  features.home.ai.dsh = out;

  # Home Manager Modules
  flake.homeModules.dsh.imports = [config.features.home.ai.dsh];
}

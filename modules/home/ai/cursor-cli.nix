{config, ...}: let
  out = {pkgs, ...}: {
    home.packages = [pkgs.llm-agents.cursor-agent];

    agents.md.coding-agents = [
      "- `cursor-cli`: Cursor CLI, command `cursor-agent`. Headless: `cursor-agent -p --model <model[:variant]> \"<prompt>\"`; effort is the model variant slug (e.g. `gpt-5-high`)."
    ];
  };
in {
  # Features
  features.home.ai.cursor-cli = out;

  # Home Manager Modules
  flake.homeModules.cursor-cli.imports = [config.features.home.ai.cursor-cli];
}

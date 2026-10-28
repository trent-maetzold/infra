# Cursor CLI (`cursor-agent`).
{
  config,
  jail-nix,
  ...
}: let
  inherit (config.flake.lib) makeAgentJail;
  modules.homeManager = {
    config,
    pkgs,
    ...
  }: let
    jail = makeAgentJail {inherit config jail-nix pkgs;};
  in {
    # cursor-agent has no home override, so its state stays in ~/.cursor.
    home.packages = [(jail "cursor-agent" pkgs.llm-agents.cursor-agent {state = ["${config.home.homeDirectory}/.cursor"];})];

    agents.md.coding-agents = [
      "- `cursor-cli`: Cursor CLI, command `cursor-agent`. Headless: `cursor-agent -p --model <model[:variant]> \"<prompt>\"`; effort is the model variant slug (e.g. `gpt-5-high`)."
    ];
  };
in {
  # Flake Modules
  flake.modules.homeManager.cursor-cli = modules.homeManager;
}

# Cursor CLI (`cursor-agent`).
{jail-nix, ...}: let
  modules.homeManager = {
    config,
    pkgs,
    ...
  }: let
    makeJail = import ./_lib/make-jail.nix {inherit config jail-nix pkgs;};
  in {
    # cursor-agent has no home override, so its state stays in ~/.cursor.
    home.packages = [(makeJail "cursor-agent" pkgs.llm-agents.cursor-agent {state = ["${config.home.homeDirectory}/.cursor"];})];

    agents.md.coding-agents = [
      "- `cursor-cli`: Cursor CLI, command `cursor-agent`. Headless: `cursor-agent -p --model <model[:variant]> \"<prompt>\"`; effort is the model variant slug (e.g. `gpt-5-high`)."
    ];
  };
in {
  # Flake Modules
  flake.modules.homeManager.cursor-cli = modules.homeManager;
}

# jcode, a Rust coding TUI; llm-agents, since its flake ships only a dev shell.
{config, ...}: let
  modules.homeManager = {
    config,
    pkgs,
    ...
  }: {
    home.packages = [pkgs.llm-agents.jcode];

    # jcode reads the Claude-style mcpServers file programs.mcp generates.
    home.file.".jcode/mcp.json".source = config.xdg.configFile."mcp/mcp.json".source;

    agents.md.coding-agents = [
      "- `jcode`: Rust coding TUI, ~3 MB per extra session, swarm coordination. Headless: `jcode run \"<message>\"`; add `--json` for the result alone."
    ];
  };
in {
  # Flake Modules
  flake.modules.homeManager.jcode = modules.homeManager;

  # Home Configuration Modules
  flake.homeModules.default.imports = [config.flake.modules.homeManager.jcode];
}

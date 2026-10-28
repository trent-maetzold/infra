# jcode, a Rust coding TUI; llm-agents, since its flake ships only a dev shell.
{
  config,
  jail-nix,
  ...
}: let
  modules.homeManager = {
    config,
    pkgs,
    ...
  }: let
    inherit (config.programs.mcp.servers.gateway) url;
    makeJail = import ./_lib/make-jail.nix {inherit config jail-nix pkgs;};
    JCODE_HOME = "${config.xdg.dataHome}/jcode";
  in {
    home.packages = [(makeJail "jcode" pkgs.llm-agents.jcode {env = {inherit JCODE_HOME;};})];
    home.sessionVariables = {inherit JCODE_HOME;};

    # jcode reads the Claude-style mcpServers file.
    xdg.dataFile."jcode/mcp.json".text = builtins.toJSON {
      mcpServers.gateway = {
        type = "http";
        inherit url;
      };
    };

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

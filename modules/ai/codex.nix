# OpenAI Codex CLI, jailed, with the shared AGENTS.md and the MCP gateway.
{
  config,
  jail-nix,
  ...
}: let
  inherit (config.flake.lib) makeAgentJail;

  modules.homeManager = {
    config,
    lib,
    pkgs,
    ...
  }: let
    jail = makeAgentJail {inherit config jail-nix pkgs;};
    CODEX_HOME = "${config.xdg.configHome}/codex";
  in {
    # home-manager writes codex's config under $XDG_CONFIG_HOME/codex only with this set.
    home.preferXdgDirectories = true;

    programs.codex = {
      enable = true;
      package = lib.mkDefault (jail "codex" pkgs.llm-agents.codex {env = {inherit CODEX_HOME;};});
      context = config.agents.md.text;
      enableMcpIntegration = true;
      # Codex rewrites config.toml at runtime; merge instead of a read-only store link.
      mutableSettings = true;
    };

    agents.md.coding-agents = [
      "- `codex`: OpenAI Codex CLI. Headless: `codex exec -m <model> -c model_reasoning_effort=\"<low|medium|high|xhigh|max>\" \"<prompt>\"`."
    ];
  };
in {
  # Flake Modules
  flake.modules.homeManager.codex = modules.homeManager;

  # Home Configuration Modules
  flake.homeModules.default.imports = [config.flake.modules.homeManager.codex];
}

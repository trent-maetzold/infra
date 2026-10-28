# Claude Code, jailed, with the shared AGENTS.md and the MCP gateway.
{
  config,
  jail-nix,
  ...
}: let
  modules.homeManager = {
    config,
    lib,
    pkgs,
    ...
  }: let
    makeJail = import ./_lib/make-jail.nix {inherit config jail-nix pkgs;};
    configDir = "${config.xdg.configHome}/claude";
  in {
    programs.claude-code = {
      enable = true;
      inherit configDir;
      # llm-agents' build is not marked unfree, unlike nixpkgs' claude-code.
      package = lib.mkDefault (makeJail "claude" pkgs.llm-agents.claude-code {env.CLAUDE_CONFIG_DIR = configDir;});
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

    agents.md.coding-agents = [
      "- `claude`: Claude Code. Headless: `claude -p \"<prompt>\" --model <model> --effort <low|medium|high|xhigh|max|ultracode>`."
    ];
  };
in {
  # Flake Modules
  flake.modules.homeManager.claude-code = modules.homeManager;

  # Home Configuration Modules
  flake.homeModules.default.imports = [config.flake.modules.homeManager.claude-code];
}

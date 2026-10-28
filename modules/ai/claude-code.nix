# Claude Code, jailed, with the shared AGENTS.md, MCP gateway and agent skills.
{
  agent-skills,
  config,
  i-have-adhd,
  jail-nix,
  ...
}: let
  # Keyed so makeAgentSkill can import it again without duplicate options.
  skills = {
    key = "asgard#flake.modules.homeManager.agent-skills";
    imports = [agent-skills.homeManagerModules.default];
  };

  modules.homeManager = {
    config,
    lib,
    pkgs,
    ...
  }: let
    makeJail = import ./_lib/make-jail.nix {inherit config jail-nix pkgs;};
    configDir = "${config.xdg.configHome}/claude";
  in {
    imports = [skills];

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

    programs.agent-skills = {
      enable = true;

      # The shared bundle every jailed harness reads.
      targets.agents.enable = true;

      targets.claude = {
        dest = "${configDir}/skills";
        structure = "link";
        enable = true;
      };

      # CODEX_HOME is the jail's XDG dir, so the default ~/.codex would miss it.
      targets.codex = {
        dest = "${config.xdg.configHome}/codex/skills";
        enable = true;
      };

      targets.cursor.enable = true;

      sources.i-have-adhd = {
        path = i-have-adhd;
        subdir = "skills";
      };

      skills.enable = ["i-have-adhd"];
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

  # Functions
  flake.lib.makeAgentSkill = {name, ...} @ skill: {pkgs, ...}: let
    agent-skill = pkgs.callPackage ./agents/_lib/agent-skill.nix skill;
  in {
    imports = [skills];

    programs.agent-skills = {
      sources.${name}.path = agent-skill;

      skills.explicit.${name}.from = name;
    };
  };
}

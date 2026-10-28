# Agent skills via agent-skills-nix. ~/.agents/skills (codex, pi) is one
# read-only store link, so skills installed some other way vanish and writes
# fail; ~/.claude/skills also holds home-manager's claude-code plugin. More
# skills come from skillport over the MCP gateway. Add registry skills with
# `programs.agent-skills.{sources.<name>.path, skills.enable}`, or write one with
# makeAgentSkill. `scripts` and `references` map file names to text or paths;
# scripts are executable.
{
  agent-skills,
  config,
  i-have-adhd,
  ...
}: let
  # Keyed so makeAgentSkill can import it again without duplicate options.
  skills = {
    key = "asgard#flake.modules.homeManager.agent-skills";
    imports = [agent-skills.homeManagerModules.default];
  };

  modules.homeManager = {config, ...}: {
    imports = [skills];

    programs.agent-skills = {
      enable = true;

      targets.claude = {
        dest = "${config.programs.claude-code.configDir}/skills";
        structure = "link";
      };

      sources.i-have-adhd = {
        path = i-have-adhd;
        subdir = "skills";
      };

      skills.enable = ["i-have-adhd"];
    };

    home.file.".agents/skills".source = config.programs.agent-skills.bundlePath;
  };
in {
  # Flake Modules
  flake.modules.homeManager.agent-skills = modules.homeManager;

  # Home Configuration Modules
  flake.homeModules.default.imports = [config.flake.modules.homeManager.agent-skills];

  # Functions
  flake.lib.makeAgentSkill = {name, ...} @ skill: {pkgs, ...}: let
    agent-skill = pkgs.callPackage ./_lib/agent-skill.nix skill;
  in {
    imports = [skills];

    programs.agent-skills = {
      sources.${name}.path = agent-skill;

      skills.explicit.${name}.from = name;
    };
  };
}

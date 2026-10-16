# Agent skills via agent-skills-nix, linked to ~/.agents/skills (codex, pi) and
# ~/.claude/skills. Add registry skills with
# `programs.agent-skills.{sources.<name>.path, skills.enable}`, or write one with
# makeAgentSkill. `scripts` and `references` map file names to text or paths;
# scripts are executable.
{
  agent-skills,
  config,
  i-have-adhd,
  lib,
  ...
}: let
  # Keyed so makeAgentSkill can import it again without duplicate options.
  skills = {
    key = "asgard#my.modules.ai.agent-skills.home";
    imports = [agent-skills.homeManagerModules.default];

    programs.agent-skills = {
      enable = true;

      targets = {
        agents = {
          dest = ".agents/skills";
          structure = "link";
        };

        claude = {
          dest = ".claude/skills";
          structure = "link";
        };
      };
    };
  };
in {
  # Modules
  my.modules.ai.agent-skills.home = {
    imports = [skills];

    programs.agent-skills = {
      sources.i-have-adhd = {
        path = i-have-adhd;
        subdir = "skills";
      };

      skills.enable = ["i-have-adhd"];
    };
  };

  # Home Manager Modules
  flake.homeModules.default.imports = [config.my.modules.ai.agent-skills.home];

  # Functions
  flake.lib.makeAgentSkill = {
    name,
    description,
    text,
    scripts ? {},
    references ? {},
  }: {pkgs, ...}: let
    file = dir: executable: n: content: {
      name = "${name}/${dir}/${n}";

      path =
        if builtins.isPath content
        then content
        else
          pkgs.writeTextFile {
            name = n;
            text = content;
            inherit executable;
          };
    };
  in {
    imports = [skills];

    programs.agent-skills = {
      sources.${name}.path = pkgs.runCommand "skill-${name}" {} "cp -rL ${pkgs.linkFarm name (
        [(file "." false "SKILL.md" "---\nname: ${name}\ndescription: ${builtins.toJSON description}\n---\n\n${text}")]
        ++ lib.mapAttrsToList (file "scripts" true) scripts
        ++ lib.mapAttrsToList (file "references" false) references
      )} $out";

      skills.explicit.${name}.from = name;
    };
  };
}

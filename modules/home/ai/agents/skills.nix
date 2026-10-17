# Agent skills via agent-skills-nix, bundled in the store and baked into the
# `skills` CLI, so no skill file lands in home and agents reach them only
# through the CLI. Add registry skills with
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
  # Upstream's options without its home-manager install targets.
  skills = {
    key = "asgard#features.home.ai.skills";
    imports = [
      (import "${agent-skills}/modules/common.nix" {
        inherit (agent-skills) inputs;
        inherit lib;
      })
    ];
    programs.agent-skills.enable = true;
  };
in {
  # Features
  features.home.ai.skills = hm @ {pkgs, ...}: {
    imports = [skills];

    home.packages = [
      (config.flake.lib.makeCli {
        inherit pkgs;
        name = "skills";
        script = pkgs.my-clis.scripts.skills;
        env.SKILLS_DIR = hm.config.programs.agent-skills.bundlePath;
      })
    ];

    agents.md.tools = [
      "- `skills`: `skills list`, `skills search <text>`, `skills describe <name>`, `skills show <name>`."
      "- Skills live only inside the `skills` CLI, not in ~/.agents/skills or ~/.claude/skills; find and load them through it."
    ];

    programs.agent-skills = {
      sources.i-have-adhd = {
        path = i-have-adhd;
        subdir = "skills";
      };

      skills.enable = ["i-have-adhd"];
    };
  };

  # Home Manager Modules
  flake.homeModules.default.imports = [config.features.home.ai.skills];

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

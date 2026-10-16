# `agents.skills`, linked to ~/.agents/skills/<name> and handed to claude-code
# and codex, and makeAgentSkill to add one. `scripts` and `references` map file
# names to text or paths; scripts are executable.
{
  config,
  lib,
  ...
}: let
  out = {
    config,
    lib,
    ...
  }: {
    options.agents.skills = lib.mkOption {
      type = lib.types.attrsOf lib.types.path;
      default = {};
    };

    config.home.file = lib.mapAttrs' (name: source: lib.nameValuePair ".agents/skills/${name}" {inherit source;}) config.agents.skills;
  };

  # Keyed so makeAgentSkill can import it again without duplicate options.
  skills = {
    key = "asgard#features.home.ai.agent-skills";
    imports = [out];
  };
in {
  # Features
  features.home.ai.agent-skills = {
    imports = [skills];
    agents.skills = builtins.mapAttrs (name: _: ./skills + "/${name}") (builtins.readDir ./skills);
  };

  # Home Manager Modules
  flake.homeModules.default.imports = [config.features.home.ai.agent-skills];

  # Functions
  flake.lib.makeAgentSkill = {
    name,
    description,
    text,
    scripts ? {},
    references ? {},
  }: {pkgs, ...}: let
    file = dir: executable: n: content: {
      name = "${dir}/${n}";

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

    agents.skills.${name} = pkgs.linkFarm "skill-${name}" (
      [(file "." false "SKILL.md" "---\nname: ${name}\ndescription: ${builtins.toJSON description}\n---\n\n${text}")]
      ++ lib.mapAttrsToList (file "scripts" true) scripts
      ++ lib.mapAttrsToList (file "references" false) references
    );
  };
}

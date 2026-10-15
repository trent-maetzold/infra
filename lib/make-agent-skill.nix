# A full skill under ~/.agents/skills/<name>, also handed to claude-code and
# codex. `scripts` and `references` map file names to text or paths; scripts
# are executable.
{
  config,
  lib,
  ...
}: {
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
    imports = [config.features.home.ai.agents];

    agents.skills.${name} = pkgs.linkFarm "skill-${name}" (
      [(file "." false "SKILL.md" "---\nname: ${name}\ndescription: ${builtins.toJSON description}\n---\n\n${text}")]
      ++ lib.mapAttrsToList (file "scripts" true) scripts
      ++ lib.mapAttrsToList (file "references" false) references
    );
  };
}

# A full skill under ~/.agents/skills/<name>. `scripts` and `references` map
# file names to text or paths; scripts are executable.
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
  }: let
    dir = ".agents/skills/${name}";
    file = extra: content:
      (
        if builtins.isPath content
        then {source = content;}
        else {text = content;}
      )
      // extra;
  in {
    imports = [config.features.home.ai.agents];

    home.file =
      {"${dir}/SKILL.md".text = "---\nname: ${name}\ndescription: ${builtins.toJSON description}\n---\n\n${text}";}
      // lib.mapAttrs' (n: c: lib.nameValuePair "${dir}/scripts/${n}" (file {executable = true;} c)) scripts
      // lib.mapAttrs' (n: c: lib.nameValuePair "${dir}/references/${n}" (file {} c)) references;
  };
}

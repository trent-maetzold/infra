{config, ...}: let
  out = {
    config,
    lib,
    ...
  }: let
    sections = ["context" "boundaries" "workflow" "style" "commands" "tools"];
    render = name: rules: lib.optionalString (rules != []) "## ${lib.toSentenceCase name}\n\n${lib.concatLines rules}";
  in {
    imports = [features.home.packages.ai];

    options.agents = {
      # Filled by flake.lib.makeAgentRules; rendered in this order.
      rules = lib.genAttrs sections (_:
        lib.mkOption {
          type = lib.types.listOf lib.types.lines;
          default = [];
        });

      # Skill directories by name; flake.lib.makeAgentSkill adds to it.
      skills = lib.mkOption {
        type = lib.types.attrsOf lib.types.path;
        default = {};
      };

      # Rendered AGENTS.md, for agents that take it as text (claude-code, codex).
      markdown = lib.mkOption {
        type = lib.types.str;
        readOnly = true;
        default = lib.concatStringsSep "\n" (lib.filter (s: s != "") (map (s: render s config.agents.rules.${s}) sections));
      };
    };

    config = {
      agents = {
        rules.boundaries = ["- **ALWAYS** read documentation. Context7 and DeepWiki MCPs are available."];
        skills = lib.mapAttrs (name: _: ./skills + "/${name}") (builtins.readDir ./skills);
      };

      home.file =
        {".agents/AGENTS.md".text = config.agents.markdown;}
        // lib.mapAttrs' (name: source: lib.nameValuePair ".agents/skills/${name}" {inherit source;}) config.agents.skills;
    };
  };
  inherit (config) features;
in {
  # Features
  # Keyed so makeAgentRules/makeAgentSkill can import it again without duplicate options.
  features.home.ai.agents = {
    key = "asgard#features.home.ai.agents";
    imports = [out];
  };

  # Home Manager Modules
  flake.homeModules.default.imports = [config.features.home.ai.agents];
}

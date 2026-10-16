# `agents.md`, rendered to ~/.agents/AGENTS.md, and makeAgentRules to fill it:
#   makeAgentRules {boundaries = "- **NEVER** push to main.";}
{config, ...}: let
  out = {
    config,
    lib,
    ...
  }: let
    sections = ["context" "boundaries" "workflow" "style" "commands" "tools"];
    render = name: rules: lib.optionalString (rules != []) "## ${lib.toSentenceCase name}\n\n${lib.concatLines rules}";
  in {
    options.agents.md =
      lib.genAttrs sections (_:
        lib.mkOption {
          type = lib.types.listOf lib.types.lines;
          default = [];
        })
      // {
        # For agents that take AGENTS.md as text (claude-code, codex).
        text = lib.mkOption {
          type = lib.types.str;
          readOnly = true;
          default = lib.concatStringsSep "\n" (lib.filter (s: s != "") (map (s: render s config.agents.md.${s}) sections));
        };
      };

    config.home.file.".agents/AGENTS.md".text = config.agents.md.text;
  };

  # Keyed so makeAgentRules can import it again without duplicate options.
  md = {
    key = "asgard#features.home.ai.agents-md";
    imports = [out];
  };
in {
  # Features
  features.home.ai.agents-md = md;

  # Home Manager Modules
  flake.homeModules.default.imports = [config.features.home.ai.agents-md];

  # Functions
  flake.lib.makeAgentRules = sections: {
    imports = [md];
    agents.md = builtins.mapAttrs (_: rule: [rule]) sections;
  };
}

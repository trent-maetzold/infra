# `agents.rules`, rendered to ~/.agents/AGENTS.md, and makeAgentRules to fill it:
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
    options.agents = {
      rules = lib.genAttrs sections (_:
        lib.mkOption {
          type = lib.types.listOf lib.types.lines;
          default = [];
        });

      # For agents that take AGENTS.md as text (claude-code, codex).
      markdown = lib.mkOption {
        type = lib.types.str;
        readOnly = true;
        default = lib.concatStringsSep "\n" (lib.filter (s: s != "") (map (s: render s config.agents.rules.${s}) sections));
      };
    };

    config.home.file.".agents/AGENTS.md".text = config.agents.markdown;
  };
  # Keyed so makeAgentRules can import it again without duplicate options.
  rules = {
    key = "asgard#features.home.ai.agent-rules";
    imports = [out];
  };
in {
  # Features
  features.home.ai.agent-rules = rules;

  # Home Manager Modules
  flake.homeModules.default.imports = [config.features.home.ai.agent-rules];

  # Functions
  flake.lib.makeAgentRules = sections: {
    imports = [rules];
    agents.rules = builtins.mapAttrs (_: rule: [rule]) sections;
  };
}

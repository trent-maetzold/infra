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

    # Filled by flake.lib.makeAgentRules; rendered in this order.
    options.agents.rules = lib.genAttrs sections (_:
      lib.mkOption {
        type = lib.types.listOf lib.types.lines;
        default = [];
      });

    config = {
      agents.rules.boundaries = ["- **ALWAYS** read documentation. Context7 and DeepWiki MCPs are available."];

      home.file = {
        ".agents" = {
          source = ./config;
          recursive = true;
        };

        ".agents/AGENTS.md".text = lib.concatStringsSep "\n" (lib.filter (s: s != "") (map (s: render s config.agents.rules.${s}) sections));
      };
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

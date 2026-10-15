# Appends rules to sections of the global ~/.agents/AGENTS.md:
#   makeAgentRules {boundaries = "- **NEVER** push to main.";}
# Sections: context boundaries workflow style commands tools.
{config, ...}: {
  flake.lib.makeAgentRules = rules: {
    imports = [config.features.home.ai.agents];
    agents.rules = builtins.mapAttrs (_: rule: [rule]) rules;
  };
}

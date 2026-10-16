{config, ...}: let
  context7 = {pkgs, ...}: {
    home.packages = [pkgs.ctx7];
    agents.md.tools = ["- `ctx7`: current library docs: `ctx7 library <name> <query>` finds the ID, `ctx7 docs <id> <query>` fetches docs."];
  };
in {
  # Features
  features.home.ai.context7 = context7;

  # Home Manager Modules
  flake.homeModules.default.imports = [config.features.home.ai.context7];
}

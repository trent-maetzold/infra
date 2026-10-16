{config, ...}: let
  out = {...}: {
    programs.mcp = {
      enable = true;

      servers.deepwiki.url = "https://mcp.deepwiki.com/mcp";
    };
  };
in {
  # Features
  features.home.ai.mcp = out;

  # Home Manager Modules
  flake.homeModules.default.imports = [config.features.home.ai.mcp];
}

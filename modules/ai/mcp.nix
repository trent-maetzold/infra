{config, ...}: let
  out = {...}: {
    programs.mcp = {
      enable = true;

      servers = {
        context7.url = "https://mcp.context7.com/mcp";
        deepwiki.url = "https://mcp.deepwiki.com/mcp";
      };
    };
  };
in {
  # Modules
  my.modules.ai.mcp.home = out;

  # Home Manager Modules
  flake.homeModules.default.imports = [config.my.modules.ai.mcp.home];
}

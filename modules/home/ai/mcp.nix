{config, ...}: {
  flake.home.ai.mcp = {...}: {
    programs.mcp = {
      enable = true;
      servers = {
        context7.url = "https://mcp.context7.com/mcp";
        deepwiki.url = "https://mcp.deepwiki.com/mcp";
      };
    };
  };
  flake.homeModules.default.imports = [config.flake.home.ai.mcp];
}

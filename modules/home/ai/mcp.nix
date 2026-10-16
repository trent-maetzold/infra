# skillz serves ~/.agents/skills as MCP tools to agents without native skills.
{config, ...}: let
  out = {
    config,
    lib,
    pkgs,
    ...
  }: {
    programs.mcp = {
      enable = true;

      servers = {
        context7.url = "https://mcp.context7.com/mcp";
        deepwiki.url = "https://mcp.deepwiki.com/mcp";

        skillz = {
          command = lib.getExe pkgs.skillz;
          args = ["${config.home.homeDirectory}/.agents/skills"];
        };
      };
    };
  };
in {
  # Features
  features.home.ai.mcp = out;

  # Home Manager Modules
  flake.homeModules.default.imports = [config.features.home.ai.mcp];
}

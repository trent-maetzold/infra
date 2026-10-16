# MCP servers go through mcporter, not each harness.
{config, ...}: let
  mcp = {
    lib,
    pkgs,
    ...
  }: let
    servers = {
      context7.url = "https://mcp.context7.com/mcp";
      deepwiki.url = "https://mcp.deepwiki.com/mcp";
    };
  in {
    agents.md.tools = ["- `mcporter`: MCP servers (${lib.concatStringsSep ", " (lib.attrNames servers)}): `mcporter list <server>`, `mcporter call <server>.<tool> key=value`."];
    home.packages = [pkgs.llm-agents.mcporter];

    home.file.".mcporter/mcporter.json".text = builtins.toJSON {
      imports = [];
      mcpServers = servers;
    };
  };
in {
  # Features
  features.home.ai.mcp = mcp;

  # Home Manager Modules
  flake.homeModules.default.imports = [config.features.home.ai.mcp];
}

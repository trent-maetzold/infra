# mcp-cli: one CLI for every MCP server in programs.mcp plus skillz, which
# serves ~/.agents/skills as tools. skillz stays out of programs.mcp so agents
# with native skills don't see them twice.
{config, ...}: let
  out = {
    config,
    lib,
    pkgs,
    ...
  }: let
    servers =
      lib.mapAttrs (_: server:
        lib.hm.mcp.transformMcpServer {
          inherit server;
          extraTransforms = [lib.hm.mcp.addType];
          exclude = ["serverUrl"];
        })
      config.programs.mcp.servers
      // {
        skillz = {
          command = lib.getExe pkgs.skillz;
          args = ["${config.home.homeDirectory}/.agents/skills"];
        };
      };
  in {
    home.packages = [pkgs.mcp-cli];
    xdg.configFile."mcp/mcp_servers.json".source = (pkgs.formats.json {}).generate "mcp_servers.json" {mcpServers = servers;};
    agents.md.tools = ["- `mcp-cli`: every MCP tool and skill from one CLI: `mcp-cli -d` lists them, `mcp-cli info <server> <tool>` shows the schema, `mcp-cli call <server> <tool> '<json>'` runs it."];
  };
in {
  # Features
  features.home.ai.mcp-cli = out;

  # Home Manager Modules
  flake.homeModules.default.imports = [config.features.home.ai.mcp-cli];
}

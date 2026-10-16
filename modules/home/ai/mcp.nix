# Agents reach MCP servers only through mcp-cli: servers declared in
# programs.mcp.servers go into a store config baked into the mcp-cli wrapper, so
# no agent config or ~/.config file lists them. skillz serves ~/.agents/skills
# as tools.
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

    mcp-cli = pkgs.symlinkJoin {
      inherit (pkgs.mcp-cli) name meta;
      paths = [pkgs.mcp-cli];
      nativeBuildInputs = [pkgs.makeWrapper];
      postBuild = "wrapProgram $out/bin/mcp-cli --set MCP_CONFIG_PATH ${(pkgs.formats.json {}).generate "mcp_servers.json" {mcpServers = servers;}}";
    };
  in {
    programs.mcp.servers = {
      context7.url = "https://mcp.context7.com/mcp";
      deepwiki.url = "https://mcp.deepwiki.com/mcp";
    };

    home.packages = [mcp-cli];
    agents.md.tools = ["- `mcp-cli`: every MCP tool and skill from one CLI: `mcp-cli -d` lists them, `mcp-cli info <server> <tool>` shows the schema, `mcp-cli call <server> <tool> '<json>'` runs it."];
  };
in {
  # Features
  features.home.ai.mcp = out;

  # Home Manager Modules
  flake.homeModules.default.imports = [config.features.home.ai.mcp];
}

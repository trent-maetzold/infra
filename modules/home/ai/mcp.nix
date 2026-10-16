# Agents reach MCP servers only through mcp-cli: `mcp.servers`, in
# mcp_servers.json's schema, is baked into the mcp-cli wrapper, so no agent
# config or ~/.config file lists them. skillz serves ~/.agents/skills as tools.
{config, ...}: let
  out = {
    config,
    lib,
    pkgs,
    ...
  }: let
    json = pkgs.formats.json {};
  in {
    options.mcp.servers = lib.mkOption {type = lib.types.attrsOf json.type;};

    config = {
      mcp.servers = {
        context7.url = "https://mcp.context7.com/mcp";
        deepwiki.url = "https://mcp.deepwiki.com/mcp";

        skillz = {
          command = lib.getExe pkgs.skillz;
          args = ["${config.home.homeDirectory}/.agents/skills"];
        };
      };

      home.packages = [
        (pkgs.symlinkJoin {
          inherit (pkgs.mcp-cli) name meta;
          paths = [pkgs.mcp-cli];
          nativeBuildInputs = [pkgs.makeWrapper];
          postBuild = "wrapProgram $out/bin/mcp-cli --set MCP_CONFIG_PATH ${json.generate "mcp_servers.json" {mcpServers = config.mcp.servers;}}";
        })
      ];

      agents.md.tools = ["- `mcp-cli`: every MCP tool and skill from one CLI: `mcp-cli -d` lists them, `mcp-cli info <server> <tool>` shows the schema, `mcp-cli call <server> <tool> '<json>'` runs it."];
    };
  };
in {
  # Features
  features.home.ai.mcp = out;

  # Home Manager Modules
  flake.homeModules.default.imports = [config.features.home.ai.mcp];
}

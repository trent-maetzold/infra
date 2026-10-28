# The MCP server targets, as agentgateway YAML.
{lib, ...}: {
  flake.modules.homeManager.mcp = {pkgs, ...}: {
    options.mcp.targets = lib.mkOption {type = lib.types.listOf (pkgs.formats.yaml {}).type;};
  };
}

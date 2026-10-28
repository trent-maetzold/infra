# agentgateway's MCP targets, as agentgateway YAML.
{lib, ...}: {
  flake.modules.homeManager.mcp = {pkgs, ...}: {
    options.agentgateway.targets = lib.mkOption {type = lib.types.listOf (pkgs.formats.yaml {}).type;};
  };
}

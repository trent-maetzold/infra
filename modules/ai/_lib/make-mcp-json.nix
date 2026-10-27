# `programs.mcp` servers as JSON, with file-backed env wrapped into the command
# for clients that do not understand `{file:...}`.
{lib, pkgs}: servers: (pkgs.formats.json {}).generate "mcp.json" {
  mcpServers = lib.mapAttrs (name: server:
    lib.hm.mcp.transformMcpServer {
      inherit server;
      exclude = ["serverUrl"];
      extraTransforms = [
        lib.hm.mcp.addType
        (lib.hm.mcp.wrapEnvFilesCommand {inherit pkgs name;})
      ];
    })
  servers;
}

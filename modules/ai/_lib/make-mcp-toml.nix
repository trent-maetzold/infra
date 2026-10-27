# `programs.mcp` servers as maki's `mcp.toml`; env is carried by the wrapper command.
{lib, pkgs}: servers: {
  mcp = builtins.listToAttrs (map (server: {
      inherit (server) name;
      value = if server ? url then {inherit (server) url;} else {command = [server.command] ++ server.args;};
    })
    (import ./make-mcp-servers.nix {inherit lib pkgs;} servers));
}

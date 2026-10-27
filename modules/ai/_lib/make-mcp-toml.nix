# `programs.mcp` servers as maki's `mcp.toml`.
{lib}: servers: {
  mcp = builtins.listToAttrs (map (server: {
      inherit (server) name;
      value =
        if server ? url
        then {inherit (server) url;}
        else
          {command = [server.command] ++ server.args;}
          // lib.optionalAttrs (server.env != {}) {environment = server.env;};
    })
    (import ./make-mcp-servers.nix {inherit lib;} servers));
}

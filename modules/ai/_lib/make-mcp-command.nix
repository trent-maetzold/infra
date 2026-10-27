# A stdio MCP command wrapped so `programs.mcp` env reaches the server: literals
# are exported and file-backed values are read at startup, since neither autolith
# nor maki accepts file references.
{lib, pkgs}: name: server: let
  export = var: value:
    if builtins.isString value
    then "export ${var}=${lib.escapeShellArg value}"
    else "export ${var}=$(cat ${lib.escapeShellArg value.file})";
in
  pkgs.writeShellScript "mcp-${name}" ''
    ${lib.concatStringsSep "\n" (lib.mapAttrsToList export (server.env or {}))}
    exec ${lib.escapeShellArgs ([server.command] ++ (server.args or []))}
  ''

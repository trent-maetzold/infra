# `programs.mcp` servers as a list, split by transport: `url`, or `command`/`args`/`env`.
{lib}: servers: let
  literalEnv = lib.filterAttrs (_: value: builtins.isString value);
in
  lib.mapAttrsToList (name: server:
    if server.url != null
    then {
      inherit name;
      url = server.url;
    }
    else {
      inherit name;
      command = server.command;
      args = server.args;
      # `programs.mcp` allows env values from files; these config formats take literals.
      env = literalEnv (server.env or {});
    })
  (lib.filterAttrs (_: server: (server.enabled or null) != false) servers)

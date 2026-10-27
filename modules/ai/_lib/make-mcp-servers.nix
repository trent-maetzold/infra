# `programs.mcp` servers as a list, split by transport: `url`, or `command`/`args`.
# A stdio server with env gets a wrapper command, so literals and `{file = ...}`
# values both reach it without landing in a harness config.
{lib, pkgs}: servers:
  lib.mapAttrsToList (name: server:
    if server.url != null
    then {
      inherit name;
      url = server.url;
    }
    else let
      wrapped = (server.env or {}) != {};
    in {
      inherit name;
      command =
        if wrapped
        then import ./make-mcp-command.nix {inherit lib pkgs;} name server
        else server.command;
      args = if wrapped then [] else server.args;
    })
  (lib.filterAttrs (_: server: (server.enabled or null) != false) servers)

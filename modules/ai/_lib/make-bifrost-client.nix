# One `programs.mcp.servers` entry as a Bifrost `mcp.client_configs` entry.
# File-backed env becomes a wrapper command, since Bifrost only passes variables through.
{
  lib,
  pkgs,
}: name: server: let
  fileEnv = lib.filterAttrs (_: value: builtins.isAttrs value) (server.env or {});
  literalEnv = lib.filterAttrs (_: value: builtins.isString value) (server.env or {});
  wrapped = fileEnv != {};
in
  {
    inherit name;
    tools_to_execute = ["*"];
    is_code_mode_client = true;
  }
  // (
    if (server.url or null) != null
    then {
      connection_type = "http";
      connection_string = server.url;
    }
    else {
      connection_type = "stdio";
      stdio_config = {
        command =
          if wrapped
          then import ./make-mcp-command.nix {inherit lib pkgs;} name server
          else server.command;
        args =
          if wrapped
          then []
          else server.args or [];
        envs =
          if wrapped
          then []
          else builtins.attrNames literalEnv;
      };
    }
  )

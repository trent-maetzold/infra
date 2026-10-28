# `programs.mcp.servers`, mirrored at the flake level so the gateway can be built from it.
{lib, ...}: let
  fileEnv = lib.types.submodule {options.file = lib.mkOption {type = lib.types.str;};};

  server = lib.types.submodule {
    options = {
      command = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
      };
      args = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [];
      };
      env = lib.mkOption {
        type = lib.types.attrsOf (lib.types.oneOf [lib.types.str fileEnv]);
        default = {};
      };
      url = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
      };
      headers = lib.mkOption {
        type = lib.types.attrsOf lib.types.str;
        default = {};
      };
      enabled = lib.mkOption {
        type = lib.types.nullOr lib.types.bool;
        default = null;
      };
    };
  };
in {
  options.flake.programs.mcp.servers = lib.mkOption {
    type = lib.types.attrsOf server;
    default = {};
  };
}

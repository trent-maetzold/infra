{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.programs.pi-coding-agent;
  encryptedFiles = lib.filterAttrs (_: file: file != null) cfg.encryptedApiKeys;
  runtimeFiles = lib.filterAttrs (_: file: file != null) cfg.apiKeyFiles;
  environment = import ../../../../lib/credential-environment.nix {inherit lib pkgs;};
in {
  config = lib.mkIf cfg.enable (lib.mkMerge [
    (lib.mkIf (encryptedFiles != {}) {
      assertions = lib.mkAfter (lib.mapAttrsToList (name: file: {
          assertion = builtins.pathExists file;
          message = "Pi encrypted API-key source for '${name}' does not exist.";
        })
        encryptedFiles);
      age.secrets = lib.mapAttrs' (name: file: lib.nameValuePair "pi-${name}" {file = lib.mkDefault file;}) encryptedFiles;
      programs.pi-coding-agent.apiKeyFiles = lib.mapAttrs (name: _: lib.mkDefault config.age.secrets."pi-${name}".path) encryptedFiles;
    })
    (lib.mkIf (runtimeFiles != {}) {
      assertions = lib.mkAfter (lib.mapAttrsToList (name: _: {
          assertion = builtins.match "[A-Za-z_][A-Za-z0-9_]*" name != null;
          message = "Pi API-key environment variable '${name}' is not a shell identifier.";
        })
        runtimeFiles);
      home.sessionVariablesExtra = lib.mkBefore (environment runtimeFiles);
    })
  ]);

  options.programs.pi-coding-agent = {
    encryptedApiKeys = lib.mkOption {
      type = lib.types.attrsOf (lib.types.nullOr lib.types.path);
      default = {};
      description = "Encrypted age files keyed by API-key environment variable; declared only when Pi is enabled.";
    };
    apiKeyFiles = lib.mkOption {
      type = lib.types.attrsOf (lib.types.nullOr lib.types.str);
      default = {};
      description = "Runtime credential paths keyed by API-key environment variable; contents are read at shell startup, never during evaluation.";
    };
  };
}

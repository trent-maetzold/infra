{
  lib,
  pkgs,
}: files: let
  # agenix uses this runtime variable in its default decrypted paths.
  quotePath = path: lib.concatMapStringsSep ''"''${XDG_RUNTIME_DIR}"'' lib.escapeShellArg (lib.splitString "\${XDG_RUNTIME_DIR}" path);
in
  lib.concatStringsSep "\n" (lib.mapAttrsToList (name: path: ''export ${name}="$(${lib.getExe' pkgs.coreutils "cat"} -- ${quotePath path})"'') files)

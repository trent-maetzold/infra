# `/run/<name>.env`, written as root before a unit starts, from `{VAR = <value-only secret file>;}`.
{
  lib,
  pkgs,
}: name: vars: {
  file = "/run/${name}.env";

  ExecStartPre = [
    "+${pkgs.writeShellScript "${name}-env" ''
      umask 077
      {
        ${lib.concatStringsSep "\n" (lib.mapAttrsToList (var: file: ''printf '%s=%s\n' ${var} "$(<${file})"'') vars)}
      } > /run/${name}.env
    ''}"
  ];
}

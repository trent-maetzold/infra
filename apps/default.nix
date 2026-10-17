# Every PEP 723 script here runs as `nix run .#<name>`, with `tools` on PATH.
{config, ...}: {
  perSystem = {
    lib,
    pkgs,
    ...
  }: let
    tools = [pkgs.rage];
    scripts = map (lib.removeSuffix ".py") (lib.filter (lib.hasSuffix ".py") (lib.attrNames (builtins.readDir ./.)));
    cli = name:
      config.flake.lib.makeCli {
        inherit name pkgs;
        script = builtins.readFile ./${name}.py;
      };
  in {
    apps = lib.genAttrs scripts (name: {
      type = "app";
      program = lib.getExe (pkgs.writeShellApplication {
        inherit name;
        runtimeInputs = tools;
        text = ''exec ${lib.getExe (cli name)} "$@"'';
      });
    });
  };
}

# Our own Typer CLIs for agents: one PEP 723 script per CLI, `<name>.py`, also
# in `passthru.scripts` for features that wrap one with makeCli's `env`.
{config, ...}: {
  flake.overlays.my-clis = final: _prev: let
    scripts = final.lib.genAttrs ["skills"] (name: builtins.readFile ./${name}.py);
  in {
    my-clis = final.symlinkJoin {
      name = "my-clis";
      paths = final.lib.mapAttrsToList (name: script:
        config.flake.lib.makeCli {
          inherit name script;
          pkgs = final;
        })
      scripts;
      passthru = {inherit scripts;};
    };
  };

  perSystem = {pkgs, ...}: {
    packages = {inherit (pkgs) my-clis;};
  };
}

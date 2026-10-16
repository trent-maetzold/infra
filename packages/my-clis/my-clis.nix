# Our own Typer CLIs for agents: one PEP 723 script per CLI, `<name>.py`.
{config, ...}: {
  flake.overlays.my-clis = final: _prev: {
    my-clis = final.symlinkJoin {
      name = "my-clis";
      paths = map (name:
        config.flake.lib.makeCli {
          pkgs = final;
          inherit name;
          script = builtins.readFile ./${name}.py;
        }) ["skills"];
    };
  };

  perSystem = {pkgs, ...}: {
    packages = {inherit (pkgs) my-clis;};
  };
}

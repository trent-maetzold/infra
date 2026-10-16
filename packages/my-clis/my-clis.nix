{
  flake.overlays.my-clis = final: _prev: {
    my-clis = final.python3Packages.buildPythonApplication {
      pname = "my-clis";
      version = "0.1.0";
      pyproject = true;
      src = ./.;
      build-system = [final.python3Packages.hatchling];

      dependencies = with final.python3Packages; [
        pydantic
        pydantic-settings
        python-frontmatter
        typer
      ];

      meta.description = "Our own Typer CLIs for agents";
    };
  };

  perSystem = {pkgs, ...}: {
    packages = {inherit (pkgs) my-clis;};
  };
}

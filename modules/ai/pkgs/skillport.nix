# skillport-mcp, serves agent skills over MCP; from PyPI wheels.
{
  flake.overlays.skillport = final: _: let
    py = final.python3Packages;
  in {
    skillport-mcp = py.buildPythonApplication rec {
      pname = "skillport_mcp";
      version = "1.1.2";
      format = "wheel";

      src = py.fetchPypi {
        inherit pname version format;
        dist = "py3";
        python = "py3";
        hash = "sha256-KUYVdzu3mF3FqXLZnUuAO+cOhSx8+8iE2sy8bLJ9pRM=";
      };

      dependencies = with py; [
        fastmcp
        lancedb
        openai
        pylance
        tantivy
        (buildPythonPackage {
          pname = "skillport_core";
          inherit version format;

          src = fetchPypi {
            pname = "skillport_core";
            inherit version format;
            dist = "py3";
            python = "py3";
            hash = "sha256-Cy9Ss7XVbzC+1JwlQS050evNO74Mij22m6BQlpIMW+c=";
          };

          dependencies = [pydantic pydantic-settings pyyaml requests];
        })
      ];

      meta.mainProgram = "skillport-mcp";
    };
  };
}

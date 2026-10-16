{
  flake.overlays.skillz = final: _prev: {
    skillz = final.python3Packages.callPackage ({
      lib,
      buildPythonApplication,
      fetchPypi,
      uv-build,
      fastmcp,
      pyyaml,
    }:
      buildPythonApplication rec {
        pname = "skillz";
        version = "0.1.14";
        pyproject = true;

        src = fetchPypi {
          inherit pname version;
          hash = "sha256-y94sLUj2ON6iBwFJNBclfXDtT6QzO8Gi/vlo9bZIx+0=";
        };

        postPatch = ''
          substituteInPlace pyproject.toml --replace-fail "uv_build>=0.9.5,<0.10.0" uv_build
        '';

        build-system = [uv-build];
        dependencies = [fastmcp pyyaml];
        pythonImportsCheck = ["skillz"];

        meta = {
          description = "MCP server exposing agent skills as tools";
          homepage = "https://github.com/intellectronica/skillz";
          license = lib.licenses.mit;
          mainProgram = "skillz";
        };
      }) {};
  };

  perSystem = {pkgs, ...}: {
    packages = {inherit (pkgs) skillz;};
  };
}

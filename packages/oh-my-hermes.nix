{
  flake.overlays.oh-my-hermes = final: _prev: {
    oh-my-hermes = final.callPackage ({
      lib,
      python3Packages,
      fetchFromGitHub,
    }:
      python3Packages.buildPythonApplication (finalAttrs: {
        pname = "oh-my-hermes";
        version = "4.0.0";
        pyproject = true;
        __structuredAttrs = true;

        src = fetchFromGitHub {
          owner = "rlaope";
          repo = "oh-my-hermes";
          tag = "v${finalAttrs.version}";
          hash = "sha256-UzN2aFBwmNOYTZc/v2O3gJFdYPg6QOs0a0jA9CwNTu8=";
        };

        build-system = [python3Packages.setuptools];

        pythonImportsCheck = ["omh"];

        meta = {
          description = "All in one plugin for Hermes Agent: coding intelligence, long-term memory and model optimized workflow packages";
          homepage = "https://github.com/rlaope/oh-my-hermes";
          changelog = "https://github.com/rlaope/oh-my-hermes/blob/${finalAttrs.src.rev}/CHANGELOG.md";
          license = lib.licenses.mit;
          mainProgram = "omh";
        };
      })) {};
  };

  perSystem = {pkgs, ...}: {
    packages = {inherit (pkgs) oh-my-hermes;};
  };
}

{
  flake.overlays.honcho-ai = _final: prev: {
    pythonPackagesExtensions = prev.pythonPackagesExtensions ++ [
      (pyFinal: _pyPrev: {
        honcho-ai = pyFinal.callPackage ({
          lib,
          buildPythonPackage,
          fetchPypi,
          setuptools,
          wheel,
          httpx,
          pydantic,
          typing-extensions,
        }:
          buildPythonPackage (finalAttrs: {
            pname = "honcho-ai";
            version = "2.6.0";
            pyproject = true;
            __structuredAttrs = true;

            src = fetchPypi {
              pname = "honcho_ai";
              inherit (finalAttrs) version;
              hash = "sha256-p5nrn9PwLjT7KkFm2CYu1AfgLSdq1Ebmiv+zcL5F5Hw=";
            };

            build-system = [setuptools wheel];

            dependencies = [httpx pydantic typing-extensions];

            pythonImportsCheck = ["honcho"];

            meta = {
              description = "Official DX Optimized Python SDK for Honcho";
              homepage = "https://pypi.org/project/honcho-ai";
              license = lib.licenses.asl20;
            };
          })) {};
      })
    ];
  };

  perSystem = {pkgs, ...}: {
    packages.honcho-ai = pkgs.python3Packages.honcho-ai;
  };
}

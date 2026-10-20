{
  flake.overlays.honcho-ai = _final: prev: {
    pythonPackagesExtensions =
      prev.pythonPackagesExtensions
      ++ [
        (pyFinal: _pyPrev: {
          honcho-ai = pyFinal.buildPythonPackage rec {
            pname = "honcho-ai";
            version = "2.6.0";
            format = "wheel";

            src = pyFinal.fetchPypi {
              pname = "honcho_ai";
              inherit version format;
              dist = "py3";
              python = "py3";
              hash = "sha256-gZzdV3Xsrmn2F7FNYMPqPGrJQEs4IfpQy/C2gaoig88=";
            };

            dependencies = with pyFinal; [httpx pydantic];
          };
        })
      ];
  };
}

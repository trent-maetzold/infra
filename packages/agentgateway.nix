# agentgateway, an MCP gateway; upstream's static release binary.
{
  flake.overlays.agentgateway = final: _: {
    agentgateway = final.stdenvNoCC.mkDerivation rec {
      pname = "agentgateway";
      version = "1.7.0";

      src = final.fetchurl {
        url = "https://github.com/agentgateway/agentgateway/releases/download/v${version}/agentgateway-linux-amd64";
        hash = "sha256-Gy/AGi3inKETu7Yli1yuex6zxyQHHAnWh6RJEy8vQvg=";
      };

      dontUnpack = true;
      installPhase = "install -Dm755 $src $out/bin/agentgateway";
      meta.mainProgram = "agentgateway";
    };
  };
}

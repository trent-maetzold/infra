{
  flake.overlays.mcp-cli = final: _prev: {
    mcp-cli = final.callPackage ({
      lib,
      stdenvNoCC,
      fetchFromGitHub,
      bun,
      makeWrapper,
    }:
      stdenvNoCC.mkDerivation (finalAttrs: {
        pname = "mcp-cli";
        version = "0.3.0";

        src = fetchFromGitHub {
          owner = "philschmid";
          repo = "mcp-cli";
          tag = "v${finalAttrs.version}";
          hash = "sha256-S924rqlVKzUFD63NDyK5bbXnonra+/UoH6j78AAj3d0=";
        };

        node_modules = stdenvNoCC.mkDerivation {
          pname = "${finalAttrs.pname}-node_modules";
          inherit (finalAttrs) version src;
          nativeBuildInputs = [bun];
          impureEnvVars = lib.fetchers.proxyImpureEnvVars;
          buildPhase = "bun install --frozen-lockfile --production --ignore-scripts --no-progress";
          installPhase = "mkdir $out && cp -r node_modules $out";
          dontFixup = true;
          outputHashMode = "recursive";
          outputHash = "sha256-6NY8cdcoIX9IWSVwct4cCGzICNz7ATgPtFYm6xfIB3g=";
        };

        nativeBuildInputs = [makeWrapper];

        # The daemon re-runs `bun run src/daemon.ts`, so bun stays on PATH.
        installPhase = ''
          mkdir -p $out/lib/mcp-cli $out/bin
          cp -r src package.json $out/lib/mcp-cli
          ln -s ${finalAttrs.node_modules}/node_modules $out/lib/mcp-cli/node_modules
          makeWrapper ${lib.getExe bun} $out/bin/mcp-cli \
            --prefix PATH : ${lib.makeBinPath [bun]} \
            --add-flags "run $out/lib/mcp-cli/src/index.ts"
        '';

        meta = {
          description = "Lightweight CLI for MCP servers";
          homepage = "https://github.com/philschmid/mcp-cli";
          license = lib.licenses.mit;
          mainProgram = "mcp-cli";
        };
      })) {};
  };

  perSystem = {pkgs, ...}: {
    packages = {inherit (pkgs) mcp-cli;};
  };
}

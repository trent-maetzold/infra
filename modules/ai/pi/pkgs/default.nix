# pi extensions from npm, pinned in package-lock.json; `just pi-plugins` updates it.
{
  flake.overlays.pi-plugins = final: _: {
    pi-plugins = final.callPackage ({
      lib,
      stdenv,
      nodejs,
      importNpmLock,
      # A consumer's own package.json and package-lock.json, to change the set.
      npmRoot ? ./.,
    }:
      stdenv.mkDerivation (finalAttrs: {
        pname = "pi-plugins";
        version = "0";
        src = npmRoot;

        npmDeps = importNpmLock {inherit npmRoot;};
        # pi provides its own packages to extensions, so peers stay uninstalled, as with `pi install`.
        npmFlags = ["--legacy-peer-deps"];

        nativeBuildInputs = [nodejs importNpmLock.npmConfigHook];
        dontBuild = true;
        installPhase = "mkdir $out && cp -R node_modules $out";

        passthru.extensions = map (name: "${finalAttrs.finalPackage}/node_modules/${name}") (lib.attrNames (lib.importJSON (npmRoot + "/package.json")).dependencies);
      })) {};
  };
}

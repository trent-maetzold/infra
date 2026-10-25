# pi extension packages from npm, pinned in package-lock.json.
# Update: `npm update --package-lock-only --legacy-peer-deps` in this directory.
{
  flake.overlays.pi-plugins = final: _prev: {
    pi-plugins = final.callPackage ({
      stdenv,
      nodejs,
      importNpmLock,
    }:
      stdenv.mkDerivation {
        pname = "pi-plugins";
        version = "0";
        src = ./.;

        npmDeps = importNpmLock {npmRoot = ./.;};
        # pi provides its own packages to extensions, so peers stay uninstalled, as with `pi install`.
        npmFlags = ["--legacy-peer-deps"];
        npmRebuildFlags = ["--ignore-scripts"];

        nativeBuildInputs = [nodejs importNpmLock.npmConfigHook];
        dontBuild = true;
        installPhase = "mkdir $out && cp -R node_modules $out";
      }) {};
  };

  perSystem = {pkgs, ...}: {
    packages = {inherit (pkgs) pi-plugins;};
  };
}

# tredis only publishes musl linux builds, and those are statically linked, so
# the release binary installs as-is: no build, no interpreter, nothing to patch.
final: prev: let
  version = "1.2.0";

  # One entry per release asset we have a hash for; the throw keeps a new
  # platform from silently fetching a binary for the wrong one.
  targets = {
    x86_64-linux = {
      asset = "x86_64-unknown-linux-musl";
      hash = "sha256-HddBYvwji06t5UMSJZOQpBhLgnYnuaYkgU24xODVkUM=";
    };
    aarch64-linux = {
      asset = "aarch64-unknown-linux-musl";
      hash = "sha256-4f3ROQT/r50Akh2HuW8yaw7/C9l3sHaHjaw+a7OkzwM=";
    };
  };

  target =
    targets.${prev.stdenv.hostPlatform.system}
    or (throw "tredis ${version}: no release asset for ${prev.stdenv.hostPlatform.system}");
in {
  tredis = prev.stdenvNoCC.mkDerivation {
    pname = "tredis";
    inherit version;

    src = prev.fetchurl {
      url = "https://github.com/huseyinbabal/tredis/releases/download/v${version}/tredis-${target.asset}.tar.gz";
      hash = target.hash;
    };

    # The tarball is the bare binary, no top-level directory.
    sourceRoot = ".";
    dontBuild = true;

    installPhase = ''
      runHook preInstall
      install -Dm755 tredis $out/bin/tredis
      runHook postInstall
    '';

    meta = {
      description = "Terminal UI for Redis";
      homepage = "https://github.com/huseyinbabal/tredis";
      license = prev.lib.licenses.mit;
      mainProgram = "tredis";
      platforms = prev.lib.attrNames targets;
      sourceProvenance = [prev.lib.sourceTypes.binaryNativeCode];
    };
  };
}

# tredis only publishes musl linux builds, and those are statically linked, so
# the release binary installs as-is: no build, no interpreter, nothing to patch.
# `fetchFromGitHub` is no help here -- it fetches repo archives (`/archive/<rev>`),
# and the binary only exists as a release asset (`/releases/download/<tag>`).
{
  perSystem.overlays.tredis = _final: prev: let
    version = "1.2.0";

    # One entry per release asset we have a hash for; the throw keeps a new
    # platform from silently fetching a binary for the wrong one.
    assets = {
      x86_64-linux = {
        asset = "x86_64-unknown-linux-musl";
        hash = "sha256-HddBYvwji06t5UMSJZOQpBhLgnYnuaYkgU24xODVkUM=";
      };
      aarch64-linux = {
        asset = "aarch64-unknown-linux-musl";
        hash = "sha256-4f3ROQT/r50Akh2HuW8yaw7/C9l3sHaHjaw+a7OkzwM=";
      };
    };

    asset =
      assets.${prev.stdenv.hostPlatform.system}
    or (throw "tredis ${version}: no release asset for ${prev.stdenv.hostPlatform.system}");
  in {
    tredis =
      prev.runCommandLocal "tredis-${version}" {
        src = prev.fetchurl {
          url = "https://github.com/huseyinbabal/tredis/releases/download/v${version}/tredis-${asset.asset}.tar.gz";
          hash = asset.hash;
        };

        meta = {
          description = "Terminal UI for Redis";
          homepage = "https://github.com/huseyinbabal/tredis";
          license = prev.lib.licenses.mit;
          mainProgram = "tredis";
          platforms = prev.lib.attrNames assets;
          sourceProvenance = [prev.lib.sourceTypes.binaryNativeCode];
        };
      } ''
        # The tarball is the bare binary, no top-level directory.
        tar xf $src tredis
        install -Dm755 tredis $out/bin/tredis
      '';
  };
}

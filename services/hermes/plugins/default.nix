# Everything plugin-shaped about Hermes: the four plugin trees, the one Python
# client they import, and the settings that point Hermes at them. A plugin is a
# directory with plugin.yaml at its root, and `extraPlugins` wants that
# directory, so each is packed into the store.
{
  config,
  hermes-official-plugins,
  hermex-push,
  honcho,
  oh-my-hermes,
  ...
}: let
  baseUrl = config.my.endpoints.honcho.url;
  peer = config.vars.users.tm.name;

  out = {
    config,
    lib,
    pkgs,
    ...
  }: let
    # Hermex relays through its developer's worker: only he holds the APNs key.
    # Honcho is a memory provider, so `memory.provider` finds it by directory;
    # it is a plugin too, and only an enabled plugin's own hooks run.
    plugins = {
      hermex-push = "${hermex-push}/plugin";
      honcho = "${honcho}/hermes-plugin-honcho";
      memory-wiki = "${hermes-official-plugins}/memory-wiki";
      omh = "${oh-my-hermes}/src/plugin_bundle/omh";
    };

    pack = name: src: pkgs.runCommand name {} "cp -r ${src} $out";

    python = config.services.hermes-agent.package.python.pkgs;
  in {
    services.hermes-agent = {
      extraPlugins = lib.mapAttrsToList pack plugins;

      extraPythonPackages = [
        (python.buildPythonPackage rec {
          pname = "honcho_ai";
          version = "2.6.0";
          format = "wheel";

          src = pkgs.fetchPypi {
            inherit pname version format;
            dist = "py3";
            python = "py3";
            hash = "sha256-gZzdV3Xsrmn2F7FNYMPqPGrJQEs4IfpQy/C2gaoig88=";
          };

          # Its httpx/pydantic come from Hermes' sealed venv.
          dontCheckRuntimeDeps = true;
        })
      ];

      hermesHomeFiles."honcho.json" = builtins.toJSON {
        inherit baseUrl;

        hosts.hermes = {
          enabled = true;
          aiPeer = "hermes";
          peerName = peer;
          workspace = "hermes";
          # Everything the user says lands on one peer, whatever surface it came through.
          pinUserPeer = true;
        };
      };

      environment.HERMEX_PUSH_RELAY_URL = "https://hermex-relay.hermex-relay.workers.dev";

      settings = {
        # extraPlugins link as nix-managed-<name>, and providers are found by directory.
        memory.provider = "nix-managed-honcho";

        plugins.enabled = lib.attrNames plugins;
      };
    };
  };
in {
  my.services.hermes.modules = [out];
}

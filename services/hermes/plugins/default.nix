# Everything plugin-shaped about Hermes: the five plugin trees, the Python
# packages they import, and the settings that point Hermes at them. A plugin is
# a directory with plugin.yaml at its root, and `extraPlugins` wants that
# directory, so each is packed into the store.
#
# Mnemosyne ships as wheels, and its embedding stack overlaps Hermes' sealed venv
# (httpx, requests, pillow, tqdm, packaging, rich, click, ...); an extra that
# duplicates a venv package fails the build outright. So those ship flat — no
# declared dependencies, no build-time import or test checks — and their imports
# resolve from the same PYTHONPATH or from the venv underneath it.
{
  config,
  hermes-official-plugins,
  hermex-push,
  honcho,
  mnemosyne,
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
      mnemosyne = "${mnemosyne}/integrations/hermes-catalog";
      omh = "${oh-my-hermes}/src/plugin_bundle/omh";
    };

    pack = name: src: pkgs.runCommand name {} "cp -r ${src} $out";

    python = config.services.hermes-agent.package.python.pkgs;

    flat = package:
      package.overridePythonAttrs (_: {
        dependencies = [];
        dontCheckRuntimeDeps = true;
        pythonImportsCheck = [];
        doCheck = false;
        doInstallCheck = false;
      });

    wheel = pname: version: hash: url:
      python.buildPythonPackage {
        inherit pname version;

        format = "wheel";
        src = pkgs.fetchurl {
          inherit url hash;
        };

        dependencies = [];
        dontCheckRuntimeDeps = true;
        doCheck = false;
        doInstallCheck = false;
      };
  in {
    services.hermes-agent = {
      extraPlugins = lib.mapAttrsToList pack plugins;

      extraPythonPackages =
        [
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
        ]
        ++ map flat [
          python.fastembed
          python.huggingface-hub
          python.tokenizers
          python.onnxruntime
          python.numpy
          python.hf-xet
          python.filelock
          python.fsspec
          python.loguru
          python.mmh3
          python.py-rust-stemmers
          python.pystemmer
          python.pyyaml
          python.sqlite-vec
        ]
        ++ [
          # fetchPypi guesses a legacy path for these; the wheels live at hashed ones.
          (wheel "mnemosyne-memory" "4.0.0b5" "sha256-8pzHWuqQMRpRHG9f+9p74GL2VJxx+CIDPk4P14zP6kA=" "https://files.pythonhosted.org/packages/35/02/4b4a11ef721d48c6e68df9f8a434739b245f81f4e7b8bd5fd92aaaf4e5e3/mnemosyne_memory-4.0.0b5-py3-none-any.whl")
          (wheel "mnemosyne-hermes" "0.7.6" "sha256-jE7MlFO0PBoch642XdzNCeQTtDoaNqSEibHtyCGIEAs=" "https://files.pythonhosted.org/packages/68/29/3ec3f0a37cccca96095521ef79b8aab8f6c0cb5c9a57900fe1765f98ac9a/mnemosyne_hermes-0.7.6-py3-none-any.whl")
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

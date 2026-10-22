# Mnemosyne: local SQLite memory with vector + FTS5 recall. Honcho stays the
# memory provider; this adds its own store and tools.
#
# It ships as wheels, and its embedding stack overlaps Hermes' sealed venv
# (httpx, requests, pillow, tqdm, packaging, rich, click, ...); an extra that
# duplicates a venv package fails the build outright. So those ship flat — no
# declared dependencies, no build-time import or test checks — and their imports
# resolve from the same PYTHONPATH or from the venv underneath it.
{mnemosyne, ...}: let
  out = {
    config,
    pkgs,
    ...
  }: let
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
      extraPlugins = [(pkgs.runCommand "mnemosyne" {} "cp -r ${mnemosyne}/integrations/hermes-catalog $out")];

      extraPythonPackages =
        map flat [
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
    };
  };
in {
  my.services.hermes.modules = [out];
}

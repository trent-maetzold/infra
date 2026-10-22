# Mnemosyne: local SQLite memory with vector + FTS5 recall. It ships as a
# Python package, so this build is the install; Honcho stays the memory
# provider, and these are the tools until it isn't.
#
# Its embedding stack overlaps Hermes' sealed venv (httpx, requests, pillow,
# tqdm, packaging, rich, click, ...), and an extra that duplicates a venv
# package fails the build outright. So each package is shipped flat — no
# declared dependencies, no build-time import or test checks — and its imports
# resolve from this same PYTHONPATH or from the venv underneath it.
#
# The plugin source and its Python deps are both declared because this is a
# catalog provider rather than a pyproject extra: extraPlugins carries the
# tree, extraPythonPackages carries the code it imports.
{
  config,
  mnemosyne,
  ...
}: {
  my.services.hermes.modules = [
    ({
      config,
      pkgs,
      ...
    }: let
      ps = config.services.hermes-agent.package.python.pkgs;

      flat = package:
        package.overridePythonAttrs (_: {
          dependencies = [];
          dontCheckRuntimeDeps = true;
          pythonImportsCheck = [];
          doCheck = false;
          doInstallCheck = false;
        });

      wheel = pname: version: hash: url:
        ps.buildPythonPackage {
          inherit pname version hash;
          format = "wheel";
          src = pkgs.fetchurl {inherit url hash;};
          dependencies = [];
          dontCheckRuntimeDeps = true;
          doCheck = false;
          doInstallCheck = false;
        };
    in {
      my.hermes.plugins.mnemosyne.src = "${mnemosyne}/integrations/hermes-catalog";

      services.hermes-agent.extraPythonPackages =
        map flat [
          ps.fastembed
          ps.huggingface-hub
          ps.tokenizers
          ps.onnxruntime
          ps.numpy
          ps.hf-xet
          ps.filelock
          ps.fsspec
          ps.loguru
          ps.mmh3
          ps.py-rust-stemmers
          ps.pystemmer
          ps.pyyaml
          ps.sqlite-vec
        ]
        ++ [
          # fetchPypi guesses a legacy path for these; the wheels live at hashed ones.
          (wheel "mnemosyne-memory" "4.0.0b5" "sha256-8pzHWuqQMRpRHG9f+9p74GL2VJxx+CIDPk4P14zP6kA=" "https://files.pythonhosted.org/packages/35/02/4b4a11ef721d48c6e68df9f8a434739b245f81f4e7b8bd5fd92aaaf4e5e3/mnemosyne_memory-4.0.0b5-py3-none-any.whl")
          (wheel "mnemosyne-hermes" "0.7.6" "sha256-jE7MlFO0PBoch642XdzNCeQTtDoaNqSEibHtyCGIEAs=" "https://files.pythonhosted.org/packages/68/29/3ec3f0a37cccca96095521ef79b8aab8f6c0cb5c9a57900fe1765f98ac9a/mnemosyne_hermes-0.7.6-py3-none-any.whl")
        ];
    })
  ];
}

# mini-swe-agent is PyPI-only: no release binaries, nothing in nixpkgs, and the
# upstream install path is `uv tool install` -- a runtime fetch, not a build
# input. Every dependency it declares is already in nixpkgs' python set and
# satisfies its pins, so the sdist builds the usual way. The URL carries PyPI's
# hashed path because the canonical `/packages/source/...` form is a redirect,
# and the version comes from `[tool.setuptools.dynamic] version = {attr = ...}`,
# so no setuptools-scm is involved.
final: prev: let
  version = "2.4.6";
  python = prev.python3;
in {
  mini-swe-agent = python.pkgs.buildPythonApplication {
    pname = "mini-swe-agent";
    inherit version;
    pyproject = true;

    src = prev.fetchurl {
      url = "https://files.pythonhosted.org/packages/f0/ad/34da734871a702f815b75fb9f997e2fb75091736ba8ed16e4c318b558257/mini_swe_agent-${version}.tar.gz";
      hash = "sha256-BTLIGTp2NAn6UrsrWl16yQUtyxwsrkOUWxSxt/a6hpo=";
    };

    build-system = [python.pkgs.setuptools];

    dependencies = with python.pkgs; [
      datasets
      jinja2
      litellm
      openai
      platformdirs
      prompt-toolkit
      pydantic
      python-dotenv
      pyyaml
      requests
      rich
      tenacity
      textual
      typer
    ];

    # minisweagent/__init__.py creates its user config dir at import time, and
    # the sandbox's HOME is /homeless-shelter. The imports check runs after
    # install, so hand it a HOME it can write to.
    preFixup = ''
      export HOME=$(mktemp -d)
    '';

    pythonImportsCheck = ["minisweagent"];

    meta = {
      description = "Minimal AI software engineering agent";
      homepage = "https://github.com/SWE-agent/mini-swe-agent";
      license = prev.lib.licenses.mit;
      mainProgram = "mini";
    };
  };
}

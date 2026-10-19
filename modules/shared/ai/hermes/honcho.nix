# Hermes memory in a Honcho at `my.endpoints.honcho`.
{
  config,
  honcho,
  ...
}: let
  honchoAi = python:
    python.pkgs.buildPythonPackage rec {
      pname = "honcho-ai";
      version = "2.6.0";
      format = "wheel";

      src = python.pkgs.fetchPypi {
        pname = "honcho_ai";
        inherit version format;
        dist = "py3";
        python = "py3";
        hash = "sha256-gZzdV3Xsrmn2F7FNYMPqPGrJQEs4IfpQy/C2gaoig88=";
      };

      dependencies = with python.pkgs; [httpx pydantic];
    };

  agent = {pkgs, ...}: {
    services.hermes-agent = {
      extraPlugins = [(pkgs.runCommand "honcho" {} "cp -r ${honcho}/hermes-plugin-honcho $out")];
      extraPythonPackages = [(honchoAi pkgs.python3)];
      environment.HONCHO_BASE_URL = config.my.endpoints.honcho.url;
      settings.memory.provider = "honcho";
    };
  };
in {
  # Features
  features = {
    home.ai.hermes-honcho = agent;
    nixos.ai.hermes-honcho = agent;
  };
}

# Honcho memory: the provider plugin, the client it imports, and the endpoint
# services/honcho.nix serves on loopback.
{
  config,
  honcho,
  ...
}: let
  peer = config.vars.users.tm.name;

  out = {
    config,
    my,
    pkgs,
    ...
  }: let
    python = config.services.hermes-agent.package.python.pkgs;
  in {
    services.hermes-agent = {
      # A memory provider, so `memory.provider` finds it by directory; it is a
      # plugin too, and only an enabled plugin's own hooks run.
      extraPlugins = [(pkgs.runCommand "honcho" {} "cp -r ${honcho}/hermes-plugin-honcho $out")];

      # Its httpx/pydantic come from Hermes' sealed venv.
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

          dontCheckRuntimeDeps = true;
        })
      ];

      hermesHomeFiles."honcho.json" = builtins.toJSON {
        baseUrl = my.endpoints.honcho.url;

        hosts.hermes = {
          enabled = true;
          aiPeer = "hermes";
          peerName = peer;
          workspace = "hermes";
          # Everything the user says lands on one peer, whatever surface it came through.
          pinUserPeer = true;
        };
      };

      settings.memory.provider = "nix-managed-honcho";
    };
  };
in {
  my.services.hermes.modules = [out];
}

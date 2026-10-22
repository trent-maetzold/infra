# Honcho memory: the provider plugin, the client it imports, and the endpoint
# services/honcho.nix serves on loopback.
{
  config,
  honcho,
  ...
}: let
  baseUrl = config.my.endpoints.honcho.url;
  peer = config.vars.users.tm.name;
in {
  my.services.hermes.modules = [
    ({pkgs, ...} @ nixos: {
      # A memory provider, so `memory.provider` activates it by directory; it is
      # also a plugin, and only an enabled plugin's own hooks run.
      my.hermes.plugins.honcho.src = "${honcho}/hermes-plugin-honcho";

      services.hermes-agent = {
        # Its httpx/pydantic come from Hermes' sealed venv
        extraPythonPackages = [
          (nixos.config.services.hermes-agent.package.python.pkgs.buildPythonPackage rec {
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

        # extraPlugins link as nix-managed-<name>, and providers are found by directory.
        settings.memory.provider = "nix-managed-honcho";
      };
    })
  ];
}

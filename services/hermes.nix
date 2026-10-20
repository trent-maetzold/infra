# Hermes on yggdrasil; its web UI is reached over the tailnet.
{config, ...}: let
  # fj only reads its token from keys.json; build one from $CODEBERG_TOKEN per call
  forgejo = {
    lib,
    pkgs,
    ...
  }: {
    services.hermes-agent = {
      environmentFiles = ["/var/lib/secrets/codeberg-env"];

      extraPackages = [
        (pkgs.writeShellScriptBin "fj" ''
          data=$(mktemp -d)
          trap 'rm -rf "$data"' EXIT
          mkdir "$data/forgejo-cli"
          printf '{"hosts":{"codeberg.org":{"type":"Application","token":"%s"}}}' "$CODEBERG_TOKEN" > "$data/forgejo-cli/keys.json"
          XDG_DATA_HOME=$data ${lib.getExe pkgs.forgejo-cli} "$@"
        '')
      ];
    };
  };
in {
  my.services.hermes = {
    host = "yggdrasil";

    modules = [
      config.features.nixos.ai.hermes
      config.features.nixos.ai.hermes-honcho
      forgejo
      {services.hermes-agent.environmentFiles = ["/var/lib/secrets/opencode-env"];}
    ];

    routes.hermes = config.flake.lib.makeTailnetRoute config.my.endpoints.hermes-webui;
  };
}

# Hermex push: phone notifications through Hermex's relay, which can't be
# self-hosted — only its developer holds the APNs key.
{hermex-push, ...}: let
  out = {pkgs, ...}: {
    services.hermes-agent = {
      extraPlugins = [(pkgs.runCommand "hermex-push" {} "cp -r ${hermex-push}/plugin $out")];

      environment.HERMEX_PUSH_RELAY_URL = "https://hermex-relay.hermex-relay.workers.dev";
    };
  };
in {
  my.services.hermes.modules = [out];
}

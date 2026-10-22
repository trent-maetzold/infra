# Hermex push: phone notifications through Hermex's relay, which can't be
# self-hosted — only its developer holds the APNs key.
{hermex-push, ...}: {
  my.services.hermes.modules = [
    {
      my.hermes.plugins.hermex-push.src = "${hermex-push}/plugin";
      services.hermes-agent.environment.HERMEX_PUSH_RELAY_URL = "https://hermex-relay.hermex-relay.workers.dev";
    }
  ];
}

# Hermes Conduit's notifier: lifecycle events to the phone. Pairing is at runtime
# (`hermes conduit-push pair CODE`), so nothing is declared here.
{conduit-push, ...}: {
  my.services.hermes.modules = [
    {my.hermes.plugins.conduit_push.src = "${conduit-push}";}
  ];
}

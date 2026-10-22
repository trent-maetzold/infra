# Memory Wiki: a dashboard tab over local session history — subject pages, daily
# logs, and a read-only MEMORY.md / USER.md audit. UI only; it registers no tools.
{hermes-official-plugins, ...}: let
  out = {my.hermes.plugins.memory-wiki.src = "${hermes-official-plugins}/memory-wiki";};
in {
  my.services.hermes.modules = [out];
}

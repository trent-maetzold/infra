# Memory Wiki: a dashboard tab over local session history — subject pages, daily
# logs, and a read-only MEMORY.md / USER.md audit. UI only; it registers no tools.
{
  config,
  hermes-official-plugins,
  ...
}: {
  my.services.hermes.modules = [
    {my.hermes.plugins.memory-wiki.src = "${hermes-official-plugins}/memory-wiki";}
  ];
}

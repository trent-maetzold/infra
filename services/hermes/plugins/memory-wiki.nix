# Memory Wiki: a dashboard tab over local session history — subject pages, daily
# logs, and a read-only MEMORY.md / USER.md audit. UI only; it registers no tools.
{hermes-official-plugins, ...}: let
  out = {pkgs, ...}: {
    services.hermes-agent = {
      extraPlugins = [(pkgs.runCommand "memory-wiki" {} "cp -r ${hermes-official-plugins}/memory-wiki $out")];
    };
  };
in {
  my.services.hermes.modules = [out];
}

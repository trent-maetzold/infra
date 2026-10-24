# Translations from today's lib and vars to what modules read; deleted when
# makeHost and vars are rewritten. Also marked `# hack:` in lib/make-host.nix
# and vars/hosts.nix.
{
  config,
  lib,
  ...
}: {
  hosts = lib.mapAttrs (_: host: {ips.tailnet = host.tailnetIp;}) (lib.filterAttrs (_: host: host.tailnetIp != null) config.vars.hosts);
}

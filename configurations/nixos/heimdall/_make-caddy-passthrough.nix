# SNI matcher for the heimdall edge (heimdall _caddy.nix only).
#
# The edge terminates TLS for every name in services.caddy.virtualHosts and hands
# everything else to yggdrasil, so the matcher must name every local vhost or the
# name reaches the HTTP app's connection reset instead of the layer4 route.
# hostName covers the canonical name and serverAliases the rest.
#
# Empty virtualHosts yields "tls": matching the plain listener wrapper passes
# everything through, where an empty `not tls sni` would be invalid Caddyfile.
{lib}: {virtualHosts}:
if virtualHosts == {}
then "tls"
else "not tls sni ${
  lib.concatStringsSep " " (
    lib.concatMap (vhost: [vhost.hostName] ++ vhost.serverAliases) (lib.attrValues virtualHosts)
  )
}"

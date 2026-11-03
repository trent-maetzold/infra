# Headscale A records pointing every route's hostname at one ip, public ones too
# (split DNS); routes sharing a hostname (http and tcp) get one record.
{lib}: ip: routes:
map (name: {
  inherit name;
  type = "A";
  value = ip;
}) (lib.unique (lib.mapAttrsToList (_: route: route.hostname) routes))

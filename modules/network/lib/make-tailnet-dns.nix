# Headscale A records pointing every tailnet route at one ip.
{lib, ...}: {
  flake.lib.makeTailnetDNS = ip: routes:
    lib.mapAttrsToList (_: route: {
      name = route.hostname;
      type = "A";
      value = ip;
    })
    (lib.filterAttrs (_: route: route.dns == "tailnet") routes);
}

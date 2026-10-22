# Paseo on yggdrasil: on the tailnet at paseo.ts.trkm.io, and through its
# hosted relay.
{config, ...}: let
  inherit (config.flake.lib) routeHostname;
  name = "paseo";
  route = config.flake.lib.makeTailnetRoute config.my.endpoints.paseo;

  # The daemon's DNS-rebinding guard only answers the hostname traefik serves;
  # localhost and addresses stay allowed.
  hostnames = {config, ...}: {
    services.paseo.hostnames = [(routeHostname config.vars name route)];
  };
in {
  my.services.paseo = {
    host = "yggdrasil";
    modules = [config.flake.nixosModules.paseo hostnames];
    routes.${name} = route;
  };
}

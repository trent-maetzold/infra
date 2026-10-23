# The router for every route, at the tailnet's edge.
{config, ...}: {
  my.services.traefik = {
    host = "heimdall";
    modules = [config.features.nixos.network.traefik];
    routes.traefik = config.flake.lib.makeTailnetRoute config.my.endpoints.traefik;
  };
}

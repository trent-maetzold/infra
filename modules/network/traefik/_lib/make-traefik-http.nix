# Traefik routers and services for routes: tailnet ones behind the tailnet middleware.
{lib}: routes: {
  routers =
    lib.mapAttrs (name: route: {
      rule = "Host(`${route.hostname}`)";
      service = name;
      middlewares = lib.optional (!route.public) "tailnet";
    })
    routes;

  services = lib.mapAttrs (_: route: {loadBalancer.servers = [{url = "http://${route.endpoint.ip}:${toString route.endpoint.port}";}];}) routes;
}

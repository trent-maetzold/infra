# How a service is reached, for `my.services.<service>.routes`. A private route
# is for other services; a tailnet route adds a router and a headscale record;
# a public route a router and, on the edge, the ingress.
{
  flake.lib = {
    makePrivateRoute = endpoint: {
      kind = "private";
      endpoint = {inherit (endpoint) host port;};
    };

    makeTailnetRoute = endpoint: {
      kind = "tailnet";
      endpoint = {inherit (endpoint) host port;};
    };

    makePublicRoute = endpoint: {
      kind = "public";
      endpoint = {inherit (endpoint) host port;};
    };
  };
}

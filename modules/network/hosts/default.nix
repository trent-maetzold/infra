# Each host's tailnet address and the route it serves, read by traefik and
# headscale.
{
  config,
  lib,
  ...
}: let
  makeHosts = import ./_lib/make-hosts.nix {inherit lib;};
  makeRoutes = import ./_lib/make-routes.nix {inherit lib;};
in {
  hosts = makeHosts config.flake.hosts;
  routes = makeRoutes config.flake.hosts;
}

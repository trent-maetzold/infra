# Paseo daemon on loopback, on the tailnet at paseo.<tailnet domain>, and
# through its hosted relay. Reusable as `asgard.modules.nixos.paseo`, activated
# as `asgard.nixosModules.yggdrasil`.
{
  config,
  paseo,
  ...
}: let
  inherit (config.flake.lib) makeTailnetRoute routeHostname;

  host = "yggdrasil";
  name = "paseo";

  endpoint = {
    host = "127.0.0.1";
    port = 6767;
  };

  route = makeTailnetRoute endpoint;

  # Reusable: the daemon and every option at its default.
  nixosOut = _: {
    imports = [paseo.nixosModules.default];

    services.paseo = {
      enable = true;
      listenAddress = endpoint.host;
      inherit (endpoint) port;

      user = "paseo";
      group = "paseo";
      dataDir = "/var/lib/paseo";
      openFirewall = false;
      hostnames = [];

      relay = {
        enable = true;
        mode = "hosted";
        host = "";
        port = 443;
        useTls = true;
        publicUseTls = null;
      };

      inheritUserEnvironment = false;
      environment = {};
      # `$PASEO_HOME/config.json`
      settings = {};
    };
  };

  # Concrete: the instance yggdrasil runs.
  hosts.${host} = {config, ...}: {
    imports = [nixosOut];

    # The daemon's DNS-rebinding guard only answers the hostname traefik serves;
    # localhost and addresses stay allowed.
    services.paseo.hostnames = [(routeHostname config.vars name route)];
  };
in {
  # Downstream: `asgard.modules.nixos.paseo`.
  flake.modules.nixos.paseo = nixosOut;

  # Downstream: `asgard.nixosModules.yggdrasil`, the module yggdrasil imports.
  flake.nixosModules.${host}.imports = [hosts.${host}];

  # Where the daemon listens, and the route traefik and headscale serve.
  my.endpoints.${name} = endpoint;
  my.routes.${name} = route // {inherit host;};
}

# Paseo daemon on loopback, on the tailnet at paseo.<tailnet domain>, and
# through its hosted relay. Reusable as `asgard.modules.nixos.paseo`, activated
# as `asgard.nixosModules.yggdrasil`.
{
  config,
  lib,
  paseo,
  ...
}: let
  port = 6767;

  modules.nixos = _: {
    imports = [paseo.nixosModules.default];

    services.paseo = {
      enable = true;
      listenAddress = lib.mkDefault "127.0.0.1";
      inherit port;

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
      settings = {};
    };
  };

  route = {
    hostname = "paseo.ts.trkm.io";
    endpoint = {
      ip = config.hosts.yggdrasil.ips.tailnet;
      inherit port;
    };
  };

  hosts.yggdrasil = {
    imports = [modules.nixos];

    services.paseo = {
      hostnames = [route.hostname];
      listenAddress = route.endpoint.ip;
      inherit (route.endpoint) port;
    };
  };
in {
  flake.modules.nixos.paseo = modules.nixos;
  flake.nixosModules.yggdrasil.imports = [hosts.yggdrasil];
  routes.paseo = route;
}

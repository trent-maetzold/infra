# yggdrasil-bmc: yggdrasil's Supermicro IPMI, on the LAN only. yggdrasil routes
# the tailnet to it, so heimdall's traefik serves it.
{config, ...}: let
  bmc = config.flake.lib.makeMachine {
    name = "yggdrasil-bmc";
    lan.address = "10.10.20.154";
  };
in {
  flake.hosts.yggdrasil-bmc = bmc;

  flake.nixosModules = {
    # The tailnet masquerades as yggdrasil, so the BMC needs no route back.
    yggdrasil.imports = [
      {
        services.tailscale = {
          useRoutingFeatures = "server";
          extraSetFlags = ["--advertise-routes=${bmc.lan.address}/32"];
        };

        networking.nat = {
          enable = true;
          internalInterfaces = ["tailscale0"];
          externalInterface = "br0";
        };
      }
    ];

    heimdall.imports = [
      {
        services.tailscale = {
          useRoutingFeatures = "client";
          extraSetFlags = ["--accept-routes"];
        };
      }
    ];
  };

  routes."bmc.yggdrasil" = {
    hostname = "bmc.yggdrasil.ts.trkm.io";

    endpoint = {
      ip = bmc.lan.address;
      port = 443;
      scheme = "https";
      insecureSkipVerify = true;
    };
  };
}

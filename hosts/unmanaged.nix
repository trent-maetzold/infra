# Machines we reach but don't build, and what reaching them takes: an address,
# an ssh entry, and the routes that get the tailnet to them.
{config, ...}: let
  # Out of band: HTTPS only, with a certificate of its own.
  bmc = {
    address = "10.10.20.154";
    hostname = "bmc.yggdrasil.ts.trkm.io";
  };

  inherit (config.flake.lib) makeMachine;
in {
  # Unmanaged Hosts
  flake.hosts.yggdrasil-bmc = makeMachine {
    name = "yggdrasil-bmc";
    inherit (bmc) address;

    # Through yggdrasil; the BMC needs no route back.
    ssh.yggdrasil-bmc = {
      User = "root";
      ProxyJump = "yggdrasil";
    };
  };

  # Routes
  routes.bmc = {
    inherit (bmc) hostname;

    endpoint = {
      ip = bmc.address;
      port = 443;
      scheme = "https";
      insecureSkipVerify = true;
    };
  };

  # NixOS Configuration Modules
  flake.nixosModules.yggdrasil.imports = [
    {
      services.tailscale = {
        useRoutingFeatures = "server";
        extraSetFlags = ["--advertise-routes=${bmc.address}/32"];
      };

      networking.nat = {
        enable = true;
        internalInterfaces = ["tailscale0"];
        externalInterface = "br0";
      };
    }
  ];

  flake.nixosModules.heimdall.imports = [
    {
      services.tailscale = {
        useRoutingFeatures = "client";
        extraSetFlags = ["--accept-routes"];
      };
    }
  ];
}

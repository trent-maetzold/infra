# Machines we reach but don't build: a map of their addresses and ssh entries,
# each a `flake.hosts` entry with no system. yggdrasil routes the tailnet to
# their LAN addresses, so they are reached over it.
{
  config,
  lib,
  ...
}: let
  inherit (config.flake.lib) makeMachine;

  machines = {
    yggdrasil-bmc = {
      address = "10.10.20.154";
      domain = "bmc.yggdrasil.ts.trkm.io";

      # Over the tailnet, through yggdrasil; the BMC needs no route back.
      ssh = {
        User = "root";
        ProxyJump = "yggdrasil";
      };
    };
  };

  routed = lib.filterAttrs (_: m: m ? domain) machines;
in {
  flake.hosts = builtins.mapAttrs (name: m:
    makeMachine {
      inherit name;
      inherit (m) address;
      ssh = lib.optionalAttrs (m ? ssh) {"${name}" = m.ssh;};
    })
  machines;

  routes =
    builtins.mapAttrs (_: m: {
      hostname = m.domain;

      endpoint = {
        ip = m.address;
        port = 443;
        scheme = "https";
        insecureSkipVerify = true;
      };
    })
    routed;

  flake.nixosModules.yggdrasil.imports = [
    {
      services.tailscale = {
        useRoutingFeatures = "server";
        extraSetFlags = map (m: "--advertise-routes=${m.address}/32") (lib.attrValues routed);
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

# Machines we reach but don't build: what they are, and what reaching them
# takes.
{config, ...}: let
  inherit (config.flake.lib) makeHost;

  # Out of band, with a certificate of its own.
  bmc = {
    address = "10.10.20.154";
    domain = "bmc.yggdrasil.ts.trkm.io";
  };
in {
  flake.hosts.yggdrasil-bmc = makeHost {
    name = "yggdrasil-bmc";
    inherit (bmc) address domain;

    endpoint = {
      port = 443;
      scheme = "https";
      insecureSkipVerify = true;
    };

    # Through yggdrasil; the BMC needs no route back.
    ssh.yggdrasil-bmc = {
      User = "root";
      ProxyJump = "yggdrasil";
    };
  };

  # The tailnet reaches it through yggdrasil.
  flake.nixosModules.yggdrasil.imports = [
    {services.tailscale.extraSetFlags = ["--advertise-routes=${bmc.address}/32"];}
  ];
}

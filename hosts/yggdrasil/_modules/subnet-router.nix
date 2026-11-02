# yggdrasil routes the tailnet to the LAN, so the machines there are reached
# through it.
{
  services.tailscale.useRoutingFeatures = "server";

  networking.nat = {
    enable = true;
    internalInterfaces = ["tailscale0"];
    externalInterface = "br0";
  };
}

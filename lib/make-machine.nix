# A machine this flake's hosts reach, NixOS or not: its addresses, ssh entries
# and, when it serves one, the route to it. `makeHost` adds the NixOS parts.
{lib, ...}: {
  flake.lib.makeMachine = {
    name,
    address ? name,
    tailnetIp ? null,
    lan ? {},
    ssh ? {},
    domain ? null,
    endpoint ? {},
  }:
    {
      inherit name tailnetIp lan;

      ssh = lib.recursiveUpdate ({${name}.HostName = address;} // lib.optionalAttrs (lan ? address) {"${name}-lan".HostName = lan.address;}) ssh;
    }
    // lib.optionalAttrs (domain != null) {
      route = {
        hostname = domain;
        endpoint = {ip = address;} // endpoint;
      };
    };
}

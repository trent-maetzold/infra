# A machine this flake's hosts reach, NixOS or not: its addresses and ssh
# entries. `makeHost` adds the NixOS parts.
{lib, ...}: {
  flake.lib.makeMachine = {
    name,
    address ? name,
    tailnetIp ? null,
    lan ? {},
    ssh ? {},
  }: {
    inherit name tailnetIp lan;
    ssh = lib.recursiveUpdate ({${name}.HostName = address;} // lib.optionalAttrs (lan ? address) {"${name}-lan".HostName = lan.address;}) ssh;
  };
}

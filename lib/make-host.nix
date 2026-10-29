# A NixOS host. `imports` carries the profiles (`asgard.nixosModules.*`) and
# plain host modules.
# `users` takes makeUser results. Returns the module, the nixosConfiguration and,
# when `deployment` is set, a colmena node.
{
  config,
  lib,
  nixpkgs,
  ...
}: {
  flake.lib.makeHost = {
    name,
    system,
    imports ? [],
    users ? [],
    specialArgs ? {},
    address ? name,
    hostId ? null,
    tailnetIp ? null,
    lan ? {},
    ssh ? {},
    deployment ? null,
  }: let
    # The interfaces bond into bond0 behind br0, which holds the address.
    iface =
      if lan.interfaces or [] == []
      then "eth0"
      else "br0";
    nixosModule = {options, ...}: {
      imports = imports ++ map (u: u.nixosModule) users;

      config = lib.mkMerge [
        {
          nixpkgs.hostPlatform = system;
          networking.hostName = name;
        }
        (lib.mkIf (hostId != null) {networking.hostId = hostId;})
        (lib.mkIf (lan ? gateway) {
          networking =
            {
              defaultGateway = lan.gateway;
              nameservers = lan.nameservers or [];
              interfaces.${iface}.ipv4.addresses = [{inherit (lan) address prefixLength;}];
            }
            // lib.optionalAttrs (iface == "br0") {
              bonds.bond0.interfaces = lan.interfaces;
              bridges.br0.interfaces = ["bond0"];
            };
        })
        (lib.optionalAttrs (options ? wsl && users != []) {wsl.defaultUser = (lib.head users).name;})
      ];
    };
  in let
    # Each deployment key's file reaches features as the arg named after it.
    # Returned so the colmena hive's nodeSpecialArgs agrees with nixosSystem's.
    hostSpecialArgs = specialArgs // lib.mapAttrs (key: value: (value.destDir or "/run/keys") + "/${key}") (deployment.keys or {});
  in
    {
      inherit name system nixosModule tailnetIp;
      specialArgs = hostSpecialArgs;

      nixosConfiguration = nixpkgs.lib.nixosSystem {
        specialArgs = hostSpecialArgs;
        modules = [nixosModule];
      };

      ssh = lib.recursiveUpdate ({${name}.HostName = address;} // lib.optionalAttrs (lan ? address) {"${name}-lan".HostName = lan.address;}) ssh;
    }
    // lib.optionalAttrs (deployment != null) {
      colmenaNode = {
        imports = [nixosModule];
        deployment = deployment // {keys = lib.mapAttrs (_: config.flake.lib.makeDeploymentKey) deployment.keys or {};};
      };
    };
}

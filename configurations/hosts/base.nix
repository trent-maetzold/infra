# Turns `vars.hosts` into `nixosModules.<h>`, `nixosConfigurations` and colmena
# nodes. Hosts get only profiles and users; host features add themselves.
{
  config,
  lib,
  nixpkgs,
  ...
}: let
  inherit (config) vars;
  inherit (config.flake) nixosModules;

  # LAN uplink: the interfaces bond into bond0 behind br0, which holds the address.
  lan = {
    gateway,
    nameservers,
    address,
    prefixLength,
    interfaces ? [],
    ...
  }: let
    iface =
      if interfaces == []
      then "eth0"
      else "br0";
  in {
    networking =
      {
        defaultGateway = gateway;
        inherit nameservers;
        interfaces.${iface}.ipv4.addresses = [{inherit address prefixLength;}];
      }
      // lib.optionalAttrs (interfaces != []) {
        bonds.bond0 = {inherit interfaces;};
        bridges.br0.interfaces = ["bond0"];
      };
  };

  makeHost = name: {
    platform,
    profiles ? [],
    users ? [],
    ...
  } @ host: {
    imports =
      map (p: nixosModules.${p}) (["default"] ++ profiles)
      ++ map (u: nixosModules.${u}) (lib.filter (u: vars.users ? ${u}) users)
      ++ lib.optional (host.lan or {} ? gateway) (lan host.lan)
      ++ [
        {
          nixpkgs.hostPlatform = platform;
          networking.hostName = name;
        }
      ]
      ++ lib.optional (host ? hostId) {networking.hostId = host.hostId;}
      ++ lib.optional (lib.pathExists ./${name}/facter.json) {hardware.facter.reportPath = ./${name}/facter.json;}
      ++ lib.optional (lib.elem "wsl" profiles && users != []) {wsl.defaultUser = lib.head users;};
  };

  hosts = lib.filterAttrs (_: host: host ? platform) vars.hosts;
in {
  flake = {
    nixosModules = lib.mapAttrs makeHost hosts;
    nixosConfigurations = lib.mapAttrs (name: _: nixpkgs.lib.nixosSystem {modules = [nixosModules.${name}];}) hosts;
  };

  colmenaNodes = lib.mapAttrs (name: host: {
    imports = [nixosModules.${name}];
    deployment = host.deployment // {keys = lib.mapAttrs (_: config.flake.lib.makeDeploymentKey) host.deployment.keys or {};};
  }) (lib.filterAttrs (_: host: host ? deployment) hosts);
}

{
  config,
  NixVirt,
  disko,
  disko-zfs,
  nixpkgs,
  secrets,
  lib,
  ...
}: let
  inherit (config) flake;
  inherit (flake.lib) makeDeploymentKey;

  module = {
    imports =
      [
        flake.nixosModules.default
        flake.nixos.users.tm
        flake.nixos.network.tailscale-headscale
        disko.nixosModules.disko
        disko-zfs.nixosModules.default
        NixVirt.nixosModules.default
      ]
      ++ lib.attrValues flake.nixos.yggdrasil;

    nixpkgs.hostPlatform = "x86_64-linux";

    boot = {
      loader = {
        systemd-boot.enable = true;
        efi.efiSysMountPoint = "/boot/efi";
      };
      zfs.forceImportRoot = true;
    };

    hardware.facter.reportPath = ./hardware/facter.json;

    networking = {
      hostId = "6d8a7c3f";
      hostName = "yggdrasil";
      defaultGateway = "10.10.20.1";
      nameservers = ["10.10.20.1" "1.1.1.1"];
      bonds.bond0.interfaces = ["eno1" "eno2" "eno3" "eno4"];
      bridges.br0.interfaces = ["bond0"];
      interfaces.br0.ipv4.addresses = [
        {
          address = "10.10.20.10";
          prefixLength = 24;
        }
      ];
    };

    system.stateVersion = "26.11";
    home-manager.users.tm.home.stateVersion = "26.11";
  };
in {
  flake.nixosConfigurations.yggdrasil = nixpkgs.lib.nixosSystem {modules = [module];};

  colmenaNodes.yggdrasil = {
    imports = [module];

    deployment = {
      targetHost = "100.64.0.2";
      targetUser = "tm";

      keys = {
        cf-dns-api-token = makeDeploymentKey {
          secretFile = secrets + "/cf-dns-api-token.age";
          destDir = "/var/lib/secrets";
          user = "podman";
          group = "podman";
        };
        dockhand-env = makeDeploymentKey {
          secretFile = secrets + "/dockhand.env.age";
          destDir = "/var/lib/secrets";
          user = "podman";
          group = "podman";
        };
        ts-authkey = makeDeploymentKey {
          secretFile = secrets + "/ts-authkey.age";
          destDir = "/run/keys";
        };
      };
    };
  };
}

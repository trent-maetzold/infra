{
  config,
  nixpkgs,
  secrets,
  lib,
  ...
}: let
  inherit (config) flake;
  inherit (flake.lib) makeDeploymentKey;

  module = {modulesPath, ...}: {
    imports =
      [
        flake.nixosModules.default
        flake.nixos.users.tm
        flake.nixos.network.tailscale-headscale
        "${modulesPath}/profiles/qemu-guest.nix"
      ]
      ++ lib.attrValues flake.nixos.heimdall;

    nixpkgs.hostPlatform = "aarch64-linux";

    boot = {
      loader = {
        systemd-boot = {
          enable = true;
          configurationLimit = 3;
        };
        efi.canTouchEfiVariables = false;
      };
      growPartition = true;
      kernelParams = ["net.ifnames=0"];
    };

    networking = {
      hostName = "heimdall";
      useDHCP = true;
      firewall.allowedTCPPorts = [80 443];
    };

    system.stateVersion = "26.11";
    home-manager.users.tm.home.stateVersion = "26.11";
  };
in {
  flake.nixosConfigurations.heimdall = nixpkgs.lib.nixosSystem {modules = [module];};

  colmenaNodes.heimdall = {
    imports = [module];

    deployment = {
      targetHost = "hs.trkm.io";
      targetUser = "tm";
      buildOnTarget = true;

      keys = {
        cf-dns-api-token = makeDeploymentKey {
          secretFile = secrets + "/cf-dns-api-token.age";
          destDir = "/var/lib/secrets";
          user = "caddy";
          group = "caddy";
        };
        headplane-cookie-secret = makeDeploymentKey {
          secretFile = secrets + "/headplane-cookie-secret.age";
          destDir = "/var/lib/secrets";
          user = "headscale";
          group = "headscale";
        };
        ts-authkey = makeDeploymentKey {
          secretFile = secrets + "/ts-authkey.age";
          destDir = "/run/keys";
        };
      };
    };
  };
}

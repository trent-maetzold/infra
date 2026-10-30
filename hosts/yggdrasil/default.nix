# yggdrasil: the home server (Hermes, Honcho, VMs).
{
  config,
  inputs,
  ...
}: let
  inherit (config.flake) nixosModules users;
in {
  flake.hosts.yggdrasil = config.flake.lib.makeHost {
    name = "yggdrasil";
    system = "x86_64-linux";
    address = "yggdrasil.ts.trkm.io";
    tailnetIp = "100.64.0.2";
    imports = [
      nixosModules.default
      nixosModules.yggdrasil
      ./_modules/boot.nix
      ./_modules/disk-config.nix
      {sops.defaultSopsFile = ./secrets.yaml;}
      ./_modules/persistence.nix
      {hardware.facter.reportPath = ./_modules/facter.json;}
    ];
    users = [users.tm];
    hostId = "6d8a7c3f";

    specialArgs = inputs;

    lan = {
      address = "10.10.20.10";
      prefixLength = 24;
      interfaces = ["eno1" "eno2" "eno3" "eno4"];
      gateway = "10.10.20.1";
      nameservers = ["10.10.20.1" "1.1.1.1"];
    };

    secrets = {
      codeberg-token = {};
      deepseek-api-key = {};
      hermes-api-server-key = {};
      hermes-dashboard-password = {};
      honcho-db-password = {};
      openrouter-api-key = {};
      opencode-api-key = {};
      ts-authkey = {};
    };

    deployment = {
      targetHost = "100.64.0.2";
      targetUser = "tm";
    };
  };

  flake.nixosConfigurations.yggdrasil = config.flake.hosts.yggdrasil.nixosConfiguration;

  flake.nixosModules.yggdrasil = {};
}

# yggdrasil: the home server (Hermes, Honcho, VMs).
{
  config,
  inputs,
  ...
}: let
  inherit (config.flake) nixosModules users;
  secrets = "${inputs.nix-secrets}/secrets";
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
      {age.rekey.hostPubkey = "age1202c4ztpucmfws9n6jd9xk4va8ychfm273w8wrf9uwku7fuqjfaq5pljpv";}
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
      codeberg-token.rekeyFile = "${secrets}/codeberg-token.age";
      deepseek-api-key.rekeyFile = "${secrets}/deepseek-api-key.age";
      hermes-api-server-key.rekeyFile = "${secrets}/hermes-api-server-key.age";
      hermes-dashboard-password.rekeyFile = "${secrets}/hermes-dashboard-password.age";
      honcho-db-password.rekeyFile = "${secrets}/honcho-db-password.age";
      openrouter-api-key.rekeyFile = "${secrets}/openrouter-api-key.age";
      opencode-api-key.rekeyFile = "${secrets}/opencode-api-key.age";
      ts-authkey.rekeyFile = "${secrets}/ts-authkey.age";
    };

    deployment = {
      targetHost = "100.64.0.2";
      targetUser = "tm";
    };
  };

  flake.nixosConfigurations.yggdrasil = config.flake.hosts.yggdrasil.nixosConfiguration;

  flake.nixosModules.yggdrasil = {};
}

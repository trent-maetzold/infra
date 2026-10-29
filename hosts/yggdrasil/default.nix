# yggdrasil: the home server (Hermes, Honcho, VMs).
{
  config,
  inputs,
  ...
}: let
  inherit (config.flake) nixosModules users;
  secrets = "/home/tm/code/nix-secrets/secrets";
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

    deployment = {
      targetHost = "100.64.0.2";
      targetUser = "tm";

      keys = {
        codeberg-token = {
          secret = "${secrets}/hermes-codeberg-token.age";
          destDir = "/var/lib/secrets";
        };

        deepseek-api-key = {
          secret = "${secrets}/deepseek-api-key.age";
          destDir = "/var/lib/secrets";
        };

        hermes-api-server-key = {
          secret = "${secrets}/hermes-api-server-key.age";
          destDir = "/var/lib/secrets";
        };

        hermes-dashboard-password = {
          secret = "${secrets}/hermes-webui-password.age";
          destDir = "/var/lib/secrets";
        };

        honcho-db-password = {
          secret = "${secrets}/honcho-db-password.age";
          destDir = "/var/lib/secrets";
        };

        openrouter-api-key = {
          secret = "${secrets}/openrouter-api-key.age";
          destDir = "/var/lib/secrets";
        };

        opencode-api-key = {
          secret = "${secrets}/opencode-api-key.age";
          destDir = "/var/lib/secrets";
        };

        ts-authkey.secret = "${secrets}/ts-authkey.age";
      };
    };
  };

  flake.nixosConfigurations.yggdrasil = config.flake.hosts.yggdrasil.nixosConfiguration;

  flake.nixosModules.yggdrasil = {};
}

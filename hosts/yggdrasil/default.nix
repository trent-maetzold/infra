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
    imports = [nixosModules.global nixosModules.default nixosModules.tailnet ./_modules/boot.nix ./_modules/disk-config.nix ./_modules/persistence.nix {hardware.facter.reportPath = ./_modules/facter.json;}];
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
        codeberg-env = {
          secret = "${secrets}/hermes-codeberg-token.age";
          destDir = "/var/lib/secrets";
          env = "CODEBERG_TOKEN";
        };

        deepseek-env = {
          secret = "${secrets}/deepseek-api-key.age";
          destDir = "/var/lib/secrets";
          env = "DEEPSEEK_API_KEY";
        };

        hermes-api-server-env = {
          secret = "${secrets}/hermes-api-server-key.age";
          destDir = "/var/lib/secrets";
          env = "API_SERVER_KEY";
        };

        hermes-dashboard-env = {
          secret = "${secrets}/hermes-webui-password.age";
          destDir = "/var/lib/secrets";
          env = "HERMES_DASHBOARD_BASIC_AUTH_PASSWORD";
        };

        honcho-db-password = {
          secret = "${secrets}/honcho-db-password.age";
          destDir = "/var/lib/secrets";
        };

        openrouter-env = {
          secret = "${secrets}/openrouter-api-key.age";
          destDir = "/var/lib/secrets";
          env = "LLM_OPENAI_API_KEY";
        };

        opencode-env = {
          secret = "${secrets}/opencode-api-key.age";
          destDir = "/var/lib/secrets";
          env = "OPENCODE_GO_API_KEY";
        };

        ts-authkey.secret = "${secrets}/ts-authkey.age";
      };
    };
  };

  flake.nixosConfigurations.yggdrasil = config.flake.hosts.yggdrasil.nixosConfiguration;
}

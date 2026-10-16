{
  config,
  inputs,
  ...
}: let
  inherit (config.flake) nixosModules;
  inherit (config.flake.lib) makeHost;
  inherit (config.vars) global users;
  secrets = "/home/tm/code/nix-secrets/secrets";
  specialArgs = inputs;
in {
  vars.hosts = {
    heimdall = makeHost {
      name = "heimdall";
      system = "aarch64-linux";
      address = "heimdall.ts.trkm.io";
      imports = [global nixosModules.default nixosModules.qemu-guest nixosModules.tailnet ../hosts/heimdall];
      users = [users.tm-server];
      inherit specialArgs;

      deployment = {
        targetHost = "hs.trkm.io";
        targetUser = "tm";
        buildOnTarget = true;

        keys = {
          cf-dns-api-token = {
            secret = "${secrets}/cf-dns-api-token.age";
            destDir = "/var/lib/secrets";
            user = "caddy";
            group = "caddy";
          };

          headplane-cookie-secret = {
            secret = "${secrets}/headplane-cookie-secret.age";
            destDir = "/var/lib/secrets";
            user = "headscale";
            group = "headscale";
          };

          forgejo-runner-token = {
            secret = "${secrets}/forgejo-runner-token.age";
            destDir = "/var/lib/secrets";
          };

          ts-authkey.secret = "${secrets}/ts-authkey.age";
        };
      };
    };

    muninn = makeHost {
      name = "muninn";
      address = "muninn.ts.trkm.io";
      system = "x86_64-linux";
      imports = [global nixosModules.default nixosModules.wsl ../hosts/muninn];
      users = [users.tm];
      lan.address = "10.10.10.125";
      inherit specialArgs;
    };

    yggdrasil = makeHost {
      name = "yggdrasil";
      system = "x86_64-linux";
      address = "yggdrasil.ts.trkm.io";
      tailnetIp = "100.64.0.2";
      imports = [global nixosModules.default nixosModules.tailnet ../hosts/yggdrasil];
      users = [users.tm];
      hostId = "6d8a7c3f";
      inherit specialArgs;

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
          cf-dns-api-token = {
            secret = "${secrets}/cf-dns-api-token.age";
            destDir = "/var/lib/secrets";
          };

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

          dockhand-env = {
            secret = "${secrets}/dockhand.env.age";
            destDir = "/var/lib/secrets";
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
  };

  flake = {
    nixosConfigurations = {
      heimdall = config.vars.hosts.heimdall.nixosConfiguration;
      muninn = config.vars.hosts.muninn.nixosConfiguration;
      yggdrasil = config.vars.hosts.yggdrasil.nixosConfiguration;
    };

    nixosModules = {
      heimdall = config.vars.hosts.heimdall.nixosModule;
      muninn = config.vars.hosts.muninn.nixosModule;
      yggdrasil = config.vars.hosts.yggdrasil.nixosModule;
    };
  };
}

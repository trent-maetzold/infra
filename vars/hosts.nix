{
  config,
  inputs,
  ...
}: let
  inherit (config.flake) nixosModules;
  inherit (config.flake.lib) makeHost;
  inherit (config.vars) global users;
  specialArgs = inputs;
in {
  vars.hosts = {
    heimdall = makeHost {
      name = "heimdall";
      system = "aarch64-linux";
      address = "heimdall.ts.trkm.io";
      imports = [global nixosModules.default nixosModules.qemu-guest nixosModules.tailnet ../hosts/heimdall];
      users = [users.tm];
      inherit specialArgs;

      deployment = {
        targetHost = "hs.trkm.io";
        targetUser = "tm";
        buildOnTarget = true;

        keys = {
          cf-dns-api-token = {
            secret = "cf-dns-api-token.age";
            destDir = "/var/lib/secrets";
            user = "caddy";
            group = "caddy";
          };
          headplane-cookie-secret = {
            secret = "headplane-cookie-secret.age";
            destDir = "/var/lib/secrets";
            user = "headscale";
            group = "headscale";
          };
          ts-authkey.secret = "ts-authkey.age";
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
            secret = "cf-dns-api-token.age";
            destDir = "/var/lib/secrets";
            user = "podman";
            group = "podman";
          };
          dockhand-env = {
            secret = "dockhand.env.age";
            destDir = "/var/lib/secrets";
            user = "podman";
            group = "podman";
          };
          ts-authkey.secret = "ts-authkey.age";
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

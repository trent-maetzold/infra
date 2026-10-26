# heimdall: the public edge (Traefik, Headscale), an aarch64 VM.
{
  config,
  inputs,
  ...
}: let
  inherit (config.flake) nixosModules users;
  secrets = "/home/tm/code/nix-secrets/secrets";
in {
  flake.hosts.heimdall = config.flake.lib.makeHost {
    name = "heimdall";
    system = "aarch64-linux";
    address = "heimdall.ts.trkm.io";
    tailnetIp = "100.64.0.6";
    imports = [
      nixosModules.globals
      nixosModules.default
      nixosModules.heimdall
      ./_modules/boot.nix
      ./_modules/disk-config.nix
    ];
    users = [users.tm-server];
    specialArgs = inputs;

    deployment = {
      targetHost = "hs.trkm.io";
      targetUser = "tm";
      buildOnTarget = true;

      keys = {
        cf-dns-api-token = {
          secret = "${secrets}/cf-dns-api-token.age";
          destDir = "/var/lib/secrets";
          user = "traefik";
          group = "traefik";
        };

        headplane-cookie-secret = {
          secret = "${secrets}/headplane-cookie-secret.age";
          destDir = "/var/lib/secrets";
          user = "headscale";
          group = "headscale";
        };

        ts-authkey.secret = "${secrets}/ts-authkey.age";
      };
    };
  };

  flake.nixosConfigurations.heimdall = config.flake.hosts.heimdall.nixosConfiguration;
}

# heimdall: the public edge (Traefik, Headscale), an aarch64 VM.
{
  config,
  inputs,
  ...
}: let
  inherit (config.flake) nixosModules users;
  secrets = "${inputs.nix-secrets}/secrets";
in {
  flake.hosts.heimdall = config.flake.lib.makeHost {
    name = "heimdall";
    system = "aarch64-linux";
    address = "heimdall.ts.trkm.io";
    tailnetIp = "100.64.0.6";
    imports = [
      nixosModules.default
      nixosModules.heimdall
      ./_modules/boot.nix
      ./_modules/disk-config.nix
      {age.rekey.hostPubkey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILlukTGcHNI6LjpDa8pXT69rhiaWP0XQUVF2Y4TaS7ZP";}
    ];
    users = [users.tm-server];
    specialArgs = inputs;

    secrets = {
      cf-dns-api-token = {
        rekeyFile = "${secrets}/cf-dns-api-token.age";
        owner = "traefik";
        group = "traefik";
      };

      headplane-cookie-secret = {
        rekeyFile = "${secrets}/headplane-cookie-secret.age";
        owner = "headscale";
        group = "headscale";
      };

      ts-authkey.rekeyFile = "${secrets}/ts-authkey.age";
    };

    deployment = {
      targetHost = "hs.trkm.io";
      targetUser = "tm";
      buildOnTarget = true;
    };
  };

  flake.nixosConfigurations.heimdall = config.flake.hosts.heimdall.nixosConfiguration;

  flake.nixosModules.heimdall = {};
}

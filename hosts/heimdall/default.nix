# heimdall: the public edge (Traefik, Headscale), an aarch64 VM.
{
  config,
  inputs,
  ...
}: let
  inherit (config.flake) nixosModules users;
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
      {sops.defaultSopsFile = ./secrets.yaml;}
    ];
    users = [users.tm-server];
    specialArgs = inputs;

    secrets = {
      cf-dns-api-token.owner = "traefik";
      headplane-cookie-secret.owner = "headscale";
      ts-authkey = {};
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

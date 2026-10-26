# thor: the gaming PC, headless for now.
{
  config,
  inputs,
  ...
}: let
  inherit (config.flake) nixosModules users;
  secrets = "/home/tm/code/nix-secrets/secrets";
in {
  flake.hosts.thor = config.flake.lib.makeHost {
    name = "thor";
    system = "x86_64-linux";
    address = "thor.ts.trkm.io";
    imports = [nixosModules.global nixosModules.default nixosModules.preservation nixosModules.tailnet nixosModules.disko-btrfs nixosModules.disko-tmpfs-root {disko.devices.disk.main.device = "/dev/nvme0n1";}];
    users = [users.trent];
    ssh.thor.User = "trent";
    specialArgs = inputs;

    deployment = {
      targetHost = "thor.ts.trkm.io";
      targetUser = "trent";
      keys.ts-authkey.secret = "${secrets}/ts-authkey.age";
    };
  };

  flake.nixosConfigurations.thor = config.flake.hosts.thor.nixosConfiguration;
}

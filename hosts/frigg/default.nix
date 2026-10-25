# frigg: the family PC (Cinnamon, GTX 980).
{
  config,
  inputs,
  ...
}: let
  inherit (config.flake) nixosModules users;
  inherit (config.vars) global;
  secrets = "/home/tm/code/nix-secrets/secrets";
in {
  flake.hosts.frigg = config.flake.lib.makeHost {
    name = "frigg";
    system = "x86_64-linux";
    address = "frigg.ts.trkm.io";
    imports = [global nixosModules.family ./_modules/disk-config.nix ./_modules/nvidia.nix];
    users = with users; [trent justine leo violet june];
    ssh.frigg.User = "trent";
    specialArgs = inputs;

    deployment = {
      targetHost = "frigg.ts.trkm.io";
      targetUser = "trent";
      keys.ts-authkey.secret = "${secrets}/ts-authkey.age";
    };
  };

  flake.nixosConfigurations.frigg = config.flake.hosts.frigg.nixosConfiguration;
}

# muninn: the WSL workstation.
{
  config,
  inputs,
  ...
}: let
  inherit (config.flake) nixosModules users;
  inherit (config.vars) global;
in {
  flake.hosts.muninn = config.flake.lib.makeHost {
    name = "muninn";
    address = "muninn.ts.trkm.io";
    system = "x86_64-linux";
    imports = [global nixosModules.default nixosModules.wsl ./binfmt.nix];
    users = [users.tm];
    lan.address = "10.10.10.125";
    specialArgs = inputs;
  };

  flake.nixosConfigurations.muninn = config.flake.hosts.muninn.nixosConfiguration;
}

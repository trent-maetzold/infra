{
  config,
  inputs,
  ...
}: let
  inherit (config) flake;
in {
  flake.nixosConfigurations.muninn = inputs.nixpkgs.lib.nixosSystem {
    modules = [
      flake.nixosModules.default
      flake.nixosModules.tm
      {
        nixpkgs.hostPlatform = "x86_64-linux";
        networking.hostName = "muninn";

        wsl = {
          enable = true;
          defaultUser = "tm";
        };

        system.stateVersion = "26.05";
        home-manager.users.tm.home.stateVersion = "26.05";
      }
    ];
  };
}

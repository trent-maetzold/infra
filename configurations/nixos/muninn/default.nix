{
  config,
  nixpkgs,
  ...
}: let
  inherit (config) flake;
in {
  flake.nixosConfigurations.muninn = nixpkgs.lib.nixosSystem {
    modules = [
      flake.nixosModules.default
      flake.nixosModules.wsl
      flake.nixos.users.tm
      {
        nixpkgs.hostPlatform = "x86_64-linux";
        networking.hostName = "muninn";

        boot.binfmt.emulatedSystems = ["aarch64-linux"];

        wsl.defaultUser = "tm";

        system.stateVersion = "26.05";
        home-manager.users.tm.home.stateVersion = "26.05";
      }
    ];
  };
}

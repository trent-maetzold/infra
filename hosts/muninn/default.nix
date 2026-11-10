# muninn: the encrypted ephemeral-root workstation.
{
  disko,
  nixpkgs,
  preservation,
  ...
}: {
  flake.nixosConfigurations.muninn = nixpkgs.lib.nixosSystem {
    system = "x86_64-linux";
    modules = [
      disko.nixosModules.disko
      preservation.nixosModules.default
      ./_modules/configuration.nix
      ./_modules/disko.nix
      {hardware.facter.reportPath = ./facter.json;}
    ];
  };
}

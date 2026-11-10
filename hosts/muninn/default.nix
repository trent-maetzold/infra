# muninn: the encrypted ephemeral-root workstation.
{inputs, ...}: {
  flake.nixosConfigurations.muninn = inputs.nixpkgs.lib.nixosSystem {
    system = "x86_64-linux";
    modules = [
      inputs.disko.nixosModules.disko
      inputs.preservation.nixosModules.default
      ./_modules/configuration.nix
      ./_modules/disko.nix
      {hardware.facter.reportPath = ./facter.json;}
    ];
  };
}

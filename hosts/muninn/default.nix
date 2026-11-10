# muninn: the encrypted ephemeral-root workstation.
{
  config,
  inputs,
  ...
}: {
  flake.modules.nixos.muninn = {...}: {
    imports = [
      inputs.disko.nixosModules.disko
      inputs.preservation.nixosModules.default
      ./_modules/configuration.nix
      ./_modules/disko.nix
    ];

    hardware.facter.reportPath = ./facter.json;
  };

  flake.nixosModules.muninn.imports = [config.flake.modules.nixos.muninn];

  flake.nixosConfigurations.muninn = inputs.nixpkgs.lib.nixosSystem {
    system = "x86_64-linux";
    specialArgs = inputs;
    modules = [config.flake.nixosModules.muninn];
  };
}

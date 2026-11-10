# muninn: the encrypted ephemeral-root workstation.
{
  disko,
  nixpkgs,
  preservation,
  ...
}: {
  flake.nixosConfigurations.muninn = nixpkgs.lib.nixosSystem {
    system = "x86_64-linux";
    specialArgs = {inherit disko preservation;};
    modules = [
      ./_modules/configuration.nix
      ./_modules/disko.nix
    ];
  };
}

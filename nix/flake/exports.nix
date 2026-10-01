{inputs, ...}: let
  inherit (inputs.nixpkgs) lib;
  overlays = import ../overlays {
    inherit (inputs) colmena llm-agents nixpkgs;
  };

  homeManagerModules = {
    default = {...} @ args: {
      imports = [
        (inputs.import-tree ../home/modules)
        inputs.lazyvim.homeManagerModules.default
        inputs.ragenix.homeManagerModules.default
      ];

      key = "${../home}/catalog";
      config = lib.mkIf (!(args.osConfig.home-manager.useGlobalPkgs or false)) {
        nixpkgs.overlays = lib.mkBefore [overlays.default];
      };
    };
    defaults.imports = [homeManagerModules.default ../home/profiles/defaults.nix];
    development.imports = [homeManagerModules.defaults ../home/profiles/development.nix];
    secrets = inputs.ragenix.homeManagerModules.default;
    quadlet = inputs.quadlet-nix.homeManagerModules.quadlet;
  };

  nixosModules = {
    default = {
      imports = [
        (inputs.import-tree ../modules)
        nixosModules.home-manager
        inputs.nixos-wsl.nixosModules.wsl
        inputs.ragenix.nixosModules.default
      ];
    };
    defaults = {
      imports = [nixosModules.default];

      asgard.enable = lib.mkDefault true;
      home-manager.enable = lib.mkDefault true;
    };
    wsl.imports = [inputs.nixos-wsl.nixosModules.wsl ../modules/wsl.nix];
    disk.imports = [inputs.disko.nixosModules.disko inputs.disko-zfs.nixosModules.default];
    secrets = inputs.ragenix.nixosModules.default;
    quadlet = inputs.quadlet-nix.nixosModules.quadlet;
    home-manager = {
      imports = [inputs.home-manager.nixosModules.home-manager ../modules/home-manager.nix];

      key = "${../modules}/home-manager";
      nixpkgs.overlays = lib.mkBefore [overlays.default];
      home-manager.sharedModules = lib.mkAfter [homeManagerModules.default];
    };
  };
in {
  flake = {
    inherit nixosModules homeManagerModules overlays;
    lib = import ../lib {inherit inputs;};
  };
}

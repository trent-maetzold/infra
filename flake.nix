{
  description = "Asgard — opinionated NixOS + home-manager defaults";

  outputs = inputs @ {
    flake-parts,
    haumea,
    ...
  }: let
    # Every .nix file under these dirs is a flake-parts module; `_`-prefixed ones are skipped.
    discover = dirs:
      builtins.concatMap (
        dir:
          inputs.nixpkgs.lib.collect builtins.isPath (haumea.lib.load {
            src = ./. + "/${dir}";
            loader = haumea.lib.loaders.path;
          })
      )
      dirs;
  in
    flake-parts.lib.mkFlake {inherit inputs;} {
      imports =
        [
          inputs.flake-parts.flakeModules.modules
          inputs.home-manager.flakeModules.home-manager
        ]
        ++ discover ["apps" "configurations" "lib" "modules" "packages"];

      systems = ["x86_64-linux" "aarch64-linux"];
    };

  inputs = {
    # Base
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Flake
    flake-parts.url = "github:hercules-ci/flake-parts";
    haumea = {
      url = "github:nix-community/haumea";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Hardware
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    disko-zfs = {
      url = "github:numtide/disko-zfs";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.disko.follows = "disko";
    };
    nixos-wsl = {
      url = "github:nix-community/NixOS-WSL";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Infra
    colmena = {
      url = "github:zhaofengli/colmena";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    NixVirt = {
      url = "https://flakehub.com/f/AshleyYakeley/NixVirt/*.tar.gz";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Homelab
    quadlet-nix.url = "github:SEIAROTg/quadlet-nix";

    # Development
    lazyvim.url = "github:pfassina/lazyvim-nix";
    llm-agents = {
      url = "github:numtide/llm-agents.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Secrets
    secrets.url = "git+file:///home/tm/code/nix-secrets";
  };
}

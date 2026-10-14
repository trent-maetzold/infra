{
  outputs = inputs @ {
    flake-parts,
    home-manager,
    import-tree,
    ...
  }:
    flake-parts.lib.mkFlake {
      inherit inputs;
      specialArgs = inputs;
    } {
      imports = [
        home-manager.flakeModules.home-manager
        (import-tree [./apps ./configurations ./lib ./modules ./packages])
      ];

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
    import-tree.url = "github:denful/import-tree";

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
    nix-index-database = {
      url = "github:nix-community/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    lazyvim.url = "github:pfassina/lazyvim-nix";
    llm-agents = {
      url = "github:numtide/llm-agents.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Secrets
    secrets.url = "git+file:///home/tm/code/nix-secrets";
  };
}

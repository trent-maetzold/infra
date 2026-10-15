{
  outputs = inputs @ {
    nixpkgs,
    home-manager,
    flake-parts,
    import-tree,
    colmena,
    llm-agents,
    ...
  }:
    flake-parts.lib.mkFlake {
      inherit inputs;
      specialArgs = inputs;
    } ({config, ...}: {
      imports = [
        home-manager.flakeModules.home-manager
        (import-tree [./apps ./configurations ./lib ./modules ./options ./packages ./vars])
      ];

      flake.colmenaHive = colmena.lib.makeHive ({
          meta = {
            nixpkgs = import nixpkgs {system = "x86_64-linux";};
            nodeNixpkgs = nixpkgs.lib.mapAttrs (n: _: import nixpkgs {system = config.vars.hosts.${n}.platform;}) config.colmenaNodes;
          };
        }
        // config.colmenaNodes);

      systems = ["x86_64-linux" "aarch64-linux"];

      flake.overlays = {
        colmena = colmena.overlays.default;
        llm-agents = llm-agents.overlays.shared-nixpkgs;
      };

      perSystem = {
        pkgs,
        system,
        ...
      }: {
        _module.args.pkgs = import nixpkgs {
          inherit system;
          overlays = builtins.attrValues config.flake.overlays;
        };
        formatter = pkgs.alejandra;
      };
    });

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

    # Nix
    nix-index-database = {
      url = "github:nix-community/nix-index-database";
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

    # Infra
    colmena = {
      url = "github:zhaofengli/colmena";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    NixVirt = {
      url = "https://flakehub.com/f/AshleyYakeley/NixVirt/*.tar.gz";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # WSL
    nixos-wsl = {
      url = "github:nix-community/NixOS-WSL";
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

{
  outputs = inputs @ {
    nixpkgs,
    home-manager,
    flake-parts,
    import-tree,
    colmena,
    llm-agents,
    revdiff,
    ...
  }:
    flake-parts.lib.mkFlake {
      inherit inputs;
      specialArgs = inputs;
    } ({config, ...}: {
      imports = [
        flake-parts.flakeModules.modules
        home-manager.flakeModules.home-manager
        (import-tree [./apps ./hosts ./lib ./modules ./options ./packages ./users])
        ./vars.nix
      ];

      flake.colmenaHive = let
        hosts = nixpkgs.lib.filterAttrs (_: h: h ? colmenaNode) config.flake.hosts;
      in
        colmena.lib.makeHive ({
            meta = {
              nixpkgs = import nixpkgs {system = "x86_64-linux";};
              nodeNixpkgs = builtins.mapAttrs (_: h: import nixpkgs {inherit (h) system;}) hosts;
              nodeSpecialArgs = builtins.mapAttrs (_: h: h.specialArgs) hosts;
            };
          }
          // builtins.mapAttrs (_: h: h.colmenaNode) hosts);

      systems = ["x86_64-linux" "aarch64-linux" "aarch64-darwin" "x86_64-darwin"];

      flake.overlays = {
        colmena = colmena.overlays.default;
        llm-agents = llm-agents.overlays.shared-nixpkgs;
        revdiff = final: _: {revdiff = revdiff.packages.${final.stdenv.hostPlatform.system}.default;};
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

    pyproject-nix = {
      url = "github:pyproject-nix/pyproject.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    llm-agents = {
      url = "github:numtide/llm-agents.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    revdiff = {
      url = "github:umputun/revdiff";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    agent-skills = {
      url = "github:Kyure-A/agent-skills-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    hermes-agent.url = "github:NousResearch/hermes-agent";
    hermes-webui.url = "github:nesquena/hermes-webui";

    hermex-push = {
      url = "github:uzairansaruzi/hermex-push";
      flake = false;
    };

    honcho = {
      url = "github:plastic-labs/honcho";
      flake = false;
    };

    oh-my-hermes = {
      url = "github:rlaope/oh-my-hermes";
      flake = false;
    };

    paseo = {
      url = "github:getpaseo/paseo";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    i-have-adhd = {
      url = "github:ayghri/i-have-adhd";
      flake = false;
    };

    awesome-copilot = {
      url = "github:github/awesome-copilot";
      flake = false;
    };
  };
}

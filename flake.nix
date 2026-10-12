{
  description = "Asgard — opinionated NixOS + home-manager defaults";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixos-wsl = {
      url = "github:nix-community/NixOS-WSL";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    lazyvim.url = "github:pfassina/lazyvim-nix";
    llm-agents = {
      url = "github:numtide/llm-agents.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    paseo = {
      url = "github:getpaseo/paseo";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    self,
    nixpkgs,
    home-manager,
    nixos-wsl,
    lazyvim,
    llm-agents,
    paseo,
    ...
  } @ inputs: let
    nixosModules.default = ./modules;
    homeManagerModules.default = ./home/modules;

    overlays = import ./overlays {inherit nixpkgs llm-agents;};
    lib = import ./lib {
      inherit nixpkgs inputs nixosModules homeManagerModules overlays;
    };
  in {
    inherit nixosModules homeManagerModules overlays;

    packages = lib.forAllSystems (system: let
      pkgs = lib.pkgsFor system;
      nixosDoc = lib.optionsDoc pkgs (lib.evalNixos pkgs);
      homeDoc = lib.optionsDoc pkgs (lib.evalHomeManager pkgs);
    in {
      options-json = pkgs.runCommand "asgard-options-json" {} ''
        mkdir -p $out/nixos $out/home-manager
        ln -s ${nixosDoc.optionsJSON}/share/doc/nixos/options.json $out/nixos/options.json
        ln -s ${homeDoc.optionsJSON}/share/doc/nixos/options.json $out/home-manager/options.json
      '';
      options-commonmark = pkgs.runCommand "asgard-options.md" {} ''
        cat ${nixosDoc.optionsCommonMark} ${homeDoc.optionsCommonMark} > $out
      '';
    });

    formatter = lib.forAllSystems (system: (lib.pkgsFor system).alejandra);
  };
}

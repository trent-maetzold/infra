{
  description = "Asgard — opinionated NixOS + home-manager defaults";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    hermes-agent.url = "github:NousResearch/hermes-agent";
    nixos-wsl = {
      url = "github:nix-community/NixOS-WSL";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    lazyvim.url = "github:pfassina/lazyvim-nix";
    llm-agents = {
      url = "github:numtide/llm-agents.nix";
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
    ...
  } @ inputs: let
    inherit (nixpkgs) lib;

    nixosModules.default = ./modules;
    homeManagerModules.default = ./home/modules;
    specialArgs = inputs;
    overlays = [llm-agents.overlays.shared-nixpkgs];

    systems = ["x86_64-linux" "aarch64-linux"];
    forAllSystems = lib.genAttrs systems;
    pkgsFor = system: import nixpkgs {inherit system overlays;};

    checkOff = {_module.check = false;};

    evalNixos = pkgs:
      lib.evalModules {
        modules = [nixosModules.default checkOff];
        specialArgs =
          {
            modulesPath = "${nixpkgs}/nixos/modules";
            inherit pkgs;
          }
          // specialArgs;
      };

    evalHome = pkgs:
      lib.evalModules {
        modules = [homeManagerModules.default checkOff];
        specialArgs = {inherit pkgs;} // specialArgs;
      };

    optionsDoc = pkgs: eval:
      pkgs.nixosOptionsDoc {
        options = builtins.removeAttrs eval.options ["_module"];
      };
  in {
    inherit nixosModules homeManagerModules;
    overlays.default = llm-agents.overlays.shared-nixpkgs;

    packages = forAllSystems (system: let
      pkgs = pkgsFor system;
      nixosDoc = optionsDoc pkgs (evalNixos pkgs);
      homeDoc = optionsDoc pkgs (evalHome pkgs);
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

    formatter = forAllSystems (system: (pkgsFor system).alejandra);
  };
}

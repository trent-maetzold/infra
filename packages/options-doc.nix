{
  config,
  nixpkgs,
  lib,
  ...
}: {
  perSystem = {pkgs, ...}: let
    # asgard's modules are defaults, so options docs must evaluate without a full downstream config.
    eval = module: extra:
      lib.evalModules {
        modules = [module {_module.check = false;}];
        specialArgs = {inherit pkgs;} // extra;
      };
    doc = eval':
      pkgs.nixosOptionsDoc {
        options = removeAttrs eval'.options ["_module"];
      };
    nixosDoc = doc (eval config.flake.nixosModules.default {modulesPath = "${nixpkgs}/nixos/modules";});
    # nix-index-database reads this upstream home-manager option.
    homeStub = {
      options.programs.nix-index.enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        visible = false;
      };
    };
    homeDoc = doc (eval {imports = [config.flake.homeModules.default homeStub];} {});
  in {
    packages = {
      options-json = pkgs.runCommand "asgard-options-json" {} ''
        mkdir -p $out/nixos $out/home-manager
        ln -s ${nixosDoc.optionsJSON}/share/doc/nixos/options.json $out/nixos/options.json
        ln -s ${homeDoc.optionsJSON}/share/doc/nixos/options.json $out/home-manager/options.json
      '';
      options-commonmark = pkgs.runCommand "asgard-options.md" {} ''
        cat ${nixosDoc.optionsCommonMark} ${homeDoc.optionsCommonMark} > $out
      '';
    };
  };
}

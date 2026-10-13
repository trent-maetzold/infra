{config, ...}: {
  flake.modules.homeManager.languages-nix = {pkgs, ...}: {
    home.packages = with pkgs; [alejandra nil statix];
    programs.lazyvim.extras.lang.nix.enable = true;
  };
  flake.homeModules.default.imports = [config.flake.modules.homeManager.languages-nix];
}

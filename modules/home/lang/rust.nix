{config, ...}: let
  out = {pkgs, ...}: {
    home.packages = with pkgs; [lldb rustup];
    programs.lazyvim.extras.lang.rust.enable = true;
  };
in {
  # Features
  features.home.lang.rust = out;

  # Home Manager Modules
  flake.homeModules.default.imports = [config.features.home.lang.rust];
}

{config, ...}: let
  out = {pkgs, ...}: {
    home.packages = with pkgs; [lldb rustup];
    programs.lazyvim.extras.lang.rust.enable = true;
  };
in {
  # Modules
  my.modules.lang.rust.home = out;

  # Home Manager Modules
  flake.homeModules.default.imports = [config.my.modules.lang.rust.home];
}

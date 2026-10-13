{config, ...}: {
  flake.home.editor.lang.rust = {pkgs, ...}: {
    home.packages = with pkgs; [lldb rustup];
    programs.lazyvim.extras.lang.rust.enable = true;
  };
  flake.homeModules.default.imports = [config.flake.home.editor.lang.rust];
}

{config, ...}: {
  flake.modules.homeManager.languages-rust = {pkgs, ...}: {
    home.packages = with pkgs; [lldb rustup];
    programs.lazyvim.extras.lang.rust.enable = true;
  };
  flake.homeModules.default.imports = [config.flake.modules.homeManager.languages-rust];
}

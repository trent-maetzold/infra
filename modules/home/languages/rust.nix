{config, ...}: {
  flake.homeModules.languages-rust = {
    config,
    lib,
    pkgs,
    ...
  }: let
    cfg = config.languages.rust;
  in {
    config = lib.mkMerge [
      {languages.rust.enable = lib.mkDefault true;}
      (lib.mkIf cfg.enable {
        home = {
          packages = lib.mkAfter (with pkgs; [
            lldb
            rustup
          ]);
        };
        programs.lazyvim.extras.lang.rust.enable = lib.mkDefault true;
      })
    ];

    options.languages.rust.enable = lib.mkEnableOption "rust language support";
  };
  flake.homeModules.default.imports = [config.flake.homeModules.languages-rust];
}

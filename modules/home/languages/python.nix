{config, ...}: {
  flake.homeModules.languages-python = {
    config,
    lib,
    pkgs,
    ...
  }: let
    cfg = config.languages.python;
  in {
    config = lib.mkMerge [
      {languages.python.enable = lib.mkDefault true;}
      (lib.mkIf cfg.enable {
        home = {
          packages = lib.mkAfter (with pkgs; [
            basedpyright
            python3Packages.debugpy
            ruff
            uv
          ]);
        };
        programs.lazyvim.extras.lang.python.enable = lib.mkDefault true;
      })
    ];

    options.languages.python.enable = lib.mkEnableOption "python language support";
  };
  flake.homeModules.default.imports = [config.flake.homeModules.languages-python];
}

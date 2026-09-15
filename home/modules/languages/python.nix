{
  config,
  lib,
  pkgs,
  ...
}: {
  options.languages.python.enable = lib.mkEnableOption "Python language support (edit, run, debug)";

  config = lib.mkMerge [
    {languages.python.enable = lib.mkDefault true;}
    (lib.mkIf config.languages.python.enable {
      programs.lazyvim.extras.lang.python.enable = lib.mkDefault true;
      home = {
        packages = lib.mkDefault (with pkgs; [
          uv
          basedpyright
          ruff
          python3Packages.debugpy
        ]);
        file.".config/pyright/config.json".source = lib.mkDefault ../../config/lsp/pyright/config.json;
      };
    })
  ];
}

{
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
        file.".config/rust-analyzer/rust-analyzer.toml".source = lib.mkDefault ../../config/lsp/rust-analyzer/rust-analyzer.toml;
        packages = lib.mkAfter (with pkgs; [
          lldb
          rustup
        ]);
      };
      programs.lazyvim.extras.lang.rust.enable = lib.mkDefault true;
    })
  ];

  options.languages.rust.enable = lib.mkEnableOption "Rust language support (edit, build, run, debug)";
}

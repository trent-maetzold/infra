{
  config,
  lib,
  pkgs,
  ...
}: {
  options.languages.rust.enable = lib.mkEnableOption "Rust language support (edit, build, run, debug)";

  config = lib.mkMerge [
    {languages.rust.enable = lib.mkDefault true;}
    (lib.mkIf config.languages.rust.enable {
      programs.lazyvim.extras.lang.rust.enable = lib.mkDefault true;
      home = {
        packages = lib.mkAfter (with pkgs; [
          rustup
          lldb
        ]);
        file.".config/rust-analyzer/rust-analyzer.toml".source = lib.mkDefault ../../config/lsp/rust-analyzer/rust-analyzer.toml;
      };
    })
  ];
}

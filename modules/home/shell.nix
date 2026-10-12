{
  config,
  lib,
  ...
}: let
  cfg = config.programs.zsh;
in {
  config = lib.mkMerge [
    {programs.zsh.enable = lib.mkDefault true;}
    (lib.mkIf cfg.enable {
      programs = {
        starship = {
          enable = lib.mkDefault true;
          enableZshIntegration = lib.mkDefault true;
          settings = {
            add_newline = lib.mkDefault false;
            character = {
              success_symbol = lib.mkDefault "[❯](bold green)";
              error_symbol = lib.mkDefault "[❯](bold red)";
            };
          };
        };
        zsh = {
          autosuggestion.enable = lib.mkDefault true;
          oh-my-zsh = {
            enable = lib.mkDefault true;
            plugins = lib.mkAfter ["sudo"];
          };
          syntaxHighlighting.enable = lib.mkDefault true;
        };
      };
    })
  ];
}

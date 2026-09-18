{
  config,
  lib,
  ...
}: {
  config = lib.mkMerge [
    {programs.zsh.enable = lib.mkDefault true;}
    (lib.mkIf config.programs.zsh.enable {
      programs = {
        zsh = {
          autosuggestion.enable = lib.mkDefault true;
          syntaxHighlighting.enable = lib.mkDefault true;
          oh-my-zsh = {
            enable = lib.mkDefault true;
            plugins = [
              "sudo"
              "docker"
              "git"
            ];
          };
        };
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
      };
    })
  ];
}

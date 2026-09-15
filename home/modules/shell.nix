{
  config,
  lib,
  ...
}: {
  config = lib.mkMerge [
    {programs.zsh.enable = lib.mkDefault true;}
    (lib.mkIf config.programs.zsh.enable {
      programs = {
        zsh = lib.mkDefault {
          autosuggestion.enable = true;
          syntaxHighlighting.enable = true;
          oh-my-zsh = {
            enable = true;
            plugins = [
              "sudo"
              "docker"
              "git"
            ];
          };
        };
        starship = lib.mkDefault {
          enable = true;
          enableZshIntegration = true;
          settings = {
            add_newline = false;
            character = {
              success_symbol = "[❯](bold green)";
              error_symbol = "[❯](bold red)";
            };
          };
        };
      };
    })
  ];
}

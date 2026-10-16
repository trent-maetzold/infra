{config, ...}: let
  out = {...}: {
    programs = {
      starship = {
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

      zsh = {
        enable = true;
        autosuggestion.enable = true;

        oh-my-zsh = {
          enable = true;
          plugins = ["sudo"];
        };

        syntaxHighlighting.enable = true;
      };
    };
  };
in {
  # Modules
  my.modules.base.shell.home = out;

  # Home Manager Modules
  flake.homeModules.default.imports = [config.my.modules.base.shell.home];
}

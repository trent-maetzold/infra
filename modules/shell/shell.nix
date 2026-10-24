# Zsh with oh-my-zsh, autosuggestions and starship.
{config, ...}: let
  modules.homeManager = {...}: {
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
  # Flake Modules
  flake.modules.homeManager.shell = modules.homeManager;

  # Home Configuration Modules
  flake.homeModules.default.imports = [config.flake.modules.homeManager.shell];
  flake.homeModules.server.imports = [config.flake.modules.homeManager.shell];
}

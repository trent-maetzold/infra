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
  # Features
  features.home.base.shell = out;

  # Home Manager Modules
  flake.homeModules = {
    default.imports = [config.features.home.base.shell];
    server.imports = [config.features.home.base.shell];
  };
}

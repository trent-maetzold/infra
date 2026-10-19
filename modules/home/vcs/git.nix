{config, ...}: let
  out = {pkgs, ...}: {
    home = {
      packages = [pkgs.forgejo-cli];
      shellAliases.lg = "lazygit";
    };

    programs = {
      gh.enable = true;
      lazygit.enable = true;
      zsh.oh-my-zsh.plugins = ["git"];

      git = {
        enable = true;
        ignores = [".serena"];

        settings = {
          init.defaultBranch = "main";
          pull.rebase = true;
          push.autoSetupRemote = true;
        };
      };
    };
  };
in {
  # Features
  features.home.vcs.git = out;

  # Home Manager Modules
  flake.homeModules = {
    default.imports = [config.features.home.vcs.git];
    server.imports = [config.features.home.vcs.git];
  };
}

{config, ...}: {
  flake.home.vcs.git = {
    imports = [config.flake.home.packages.git];

    home.shellAliases.lg = "lazygit";

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
  flake.homeModules.default.imports = [config.flake.home.vcs.git];
}

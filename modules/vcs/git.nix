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
  # Modules
  my.modules.vcs.git.home = out;

  # Home Manager Modules
  flake.homeModules.default.imports = [config.my.modules.vcs.git.home];
}

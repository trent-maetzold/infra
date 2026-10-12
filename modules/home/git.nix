{config, ...}: let
  git = {pkgs, ...}: {
    programs.git = {
      enable = true;
      ignores = [".serena"];

      settings = {
        init.defaultBranch = "main";
        pull.rebase = true;
        push.autoSetupRemote = true;
      };

      # CLI Tools
      programs.gh.enable = true;
      home.packages = [pkgs.forgejo-cli];

      # Lazygit
      programs.lazygit.enable = true;
      home.shellAliases.lg = "lazygit";
    };
  };
in {
  flake.modules.home = {inherit git;};

  flake.homeModules = {
    develop.imports = [config.flake.modules.home.git];
    nix-admin.imports = [config.flake.modules.home.git];
  };
}

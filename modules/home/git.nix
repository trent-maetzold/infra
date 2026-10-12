{config, ...}: {
  flake.homeModules.git = {
    config,
    lib,
    pkgs,
    ...
  }: let
    cfg = config.programs.git;
  in {
    config = lib.mkMerge [
      {programs.git.enable = lib.mkDefault true;}
      (lib.mkIf cfg.enable {
        home = {
          packages = lib.mkAfter (with pkgs; [forgejo-cli]);
          shellAliases.lg = lib.mkDefault "lazygit";
        };
        programs = {
          gh.enable = lib.mkDefault true;
          git = {
            ignores = lib.mkAfter [".serena"];
            settings = {
              init.defaultBranch = lib.mkDefault "main";
              pull.rebase = lib.mkDefault true;
              push.autoSetupRemote = lib.mkDefault true;
            };
          };
          lazygit.enable = lib.mkDefault true;
          zsh.oh-my-zsh.plugins = lib.mkAfter ["git"];
        };
      })
    ];
  };
  flake.homeModules.default.imports = [config.flake.homeModules.git];
}

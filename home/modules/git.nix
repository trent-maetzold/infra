{
  config,
  lib,
  pkgs,
  ...
}: {
  config = lib.mkMerge [
    {programs.git.enable = lib.mkDefault true;}
    (lib.mkIf config.programs.git.enable {
      programs = {
        git = {
          settings = {
            init.defaultBranch = lib.mkDefault "main";
            pull.rebase = lib.mkDefault true;
            push.autoSetupRemote = lib.mkDefault true;
          };
          ignores = lib.mkDefault [".serena"];
        };
        gh.enable = lib.mkDefault true;
        lazygit.enable = lib.mkDefault true;
      };
      home = {
        packages = lib.mkAfter (with pkgs; [forgejo-cli]);
        shellAliases.lg = lib.mkDefault "lazygit";
      };
    })
  ];
}

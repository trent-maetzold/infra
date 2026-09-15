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
          settings = lib.mkDefault {
            init.defaultBranch = "main";
            pull.rebase = true;
            push.autoSetupRemote = true;
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

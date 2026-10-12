{config, ...}: {
  flake.homeModules.shell = {
    config,
    lib,
    ...
  }: let
    cfg = config.programs.zsh;
    gitCfg = config.programs.git;
  in {
    config = lib.mkMerge [
      {programs.zsh.enable = lib.mkDefault true;}
      (lib.mkIf cfg.enable {
        programs = {
          starship = {
            enable = lib.mkDefault true;
            enableZshIntegration = lib.mkDefault true;
            settings = {
              add_newline = lib.mkDefault false;
              character = {
                success_symbol = lib.mkDefault "[❯](bold green)";
                error_symbol = lib.mkDefault "[❯](bold red)";
              };
            };
          };
          zsh = {
            autosuggestion.enable = lib.mkDefault true;
            oh-my-zsh = {
              enable = lib.mkDefault true;
              plugins = ["sudo"] ++ lib.optional gitCfg.enable "git";
            };
            syntaxHighlighting.enable = lib.mkDefault true;
          };
        };
      })
    ];
  };
  flake.homeModules.default.imports = [config.flake.homeModules.shell];
}

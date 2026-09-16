{
  config,
  lib,
  pkgs,
  ...
}: {
  config = lib.mkMerge [
    {programs.tmux.enable = lib.mkDefault true;}
    (lib.mkIf config.programs.tmux.enable {
      programs.tmux = {
        terminal = lib.mkDefault "tmux-256color";
        shell = lib.mkDefault "${pkgs.zsh}/bin/zsh";
        keyMode = lib.mkDefault "vi";

        clock24 = lib.mkDefault true;
        mouse = lib.mkDefault true;
        disableConfirmationPrompt = lib.mkDefault true;

        baseIndex = lib.mkDefault 1;
        sensibleOnTop = lib.mkDefault true;

        plugins = with pkgs.tmuxPlugins; [
          tmux-which-key
        ];
        extraConfig = lib.mkDefault ''
          set -as terminal-features ",xterm*:RGB"

          set -g extended-keys on
          set -g extended-keys-format csi-u

          set -g renumber-windows on
          setw -g allow-rename off
        '';
      };
    })
  ];
}

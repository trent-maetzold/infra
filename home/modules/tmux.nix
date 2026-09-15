{
  config,
  lib,
  pkgs,
  ...
}: {
  config = lib.mkMerge [
    {programs.tmux.enable = lib.mkDefault true;}
    (lib.mkIf config.programs.tmux.enable {
      programs.tmux = lib.mkDefault {
        terminal = "tmux-256color";
        shell = "${pkgs.zsh}/bin/zsh";
        keyMode = "vi";

        clock24 = true;
        mouse = true;
        disableConfirmationPrompt = true;

        baseIndex = 1;
        sensibleOnTop = true;

        plugins = with pkgs.tmuxPlugins; [
          tmux-which-key
        ];
        extraConfig = ''
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

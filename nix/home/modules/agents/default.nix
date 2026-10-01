{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.programs.agents;
in {
  config = lib.mkIf cfg.enable {
    home.packages = lib.mkAfter (with pkgs;
      (with llm-agents; [
        agent-browser
        but
        gitnexus
        gnhf
      ])
      ++ [
        ffmpeg
        git
        jq
        tmux
        ungoogled-chromium
      ]);
  };

  options.programs.agents.enable = lib.mkEnableOption "agent tooling";
}

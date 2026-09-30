{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.programs.agents;
in {
  imports = [
    ./herdr.nix
    ./mcp.nix
    ./pi
  ];

  config = lib.mkMerge [
    {programs.agents.enable = lib.mkDefault true;}
    (lib.mkIf cfg.enable {
      home = {
        file.".agents" = {
          source = lib.mkDefault ../../config/agents;
          recursive = lib.mkDefault true;
        };
        packages = lib.mkAfter (with pkgs;
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
    })
  ];

  options.programs.agents.enable = lib.mkEnableOption "asgard's agent tooling";
}

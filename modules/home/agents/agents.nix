{config, ...}: {
  flake.homeModules.agents = {
    config,
    lib,
    pkgs,
    ...
  }: let
    cfg = config.programs.agents;
  in {
    config = lib.mkMerge [
      {programs.agents.enable = lib.mkDefault true;}
      (lib.mkIf cfg.enable {
        home = {
          file.".agents" = {
            source = lib.mkDefault ./config;
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
  };
  flake.homeModules.default.imports = [config.flake.homeModules.agents];
}

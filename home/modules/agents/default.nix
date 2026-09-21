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
    ./pi.nix
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
            bernstein
            gnhf
            openspec
            openspecui
            qmd
          ])
          ++ [
            ffmpeg
            ungoogled-chromium
          ]);
        shellAliases.mini = lib.mkDefault "uvx --from mini-swe-agent mini";
      };
    })
  ];

  options.programs.agents.enable = lib.mkEnableOption "asgard's agent tooling";
}

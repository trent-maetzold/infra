{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.programs.pi-coding-agent;
in {
  config = lib.mkMerge [
    {programs.pi-coding-agent.enable = lib.mkDefault true;}
    (lib.mkIf cfg.enable {
      home.file = {
        ".pi/agent/caveman.json".source = lib.mkDefault ../../config/pi/packages/caveman.json;
        ".pi/agent/zentui.json".source = lib.mkDefault ../../config/pi/packages/zentui.json;
      };
      programs.pi-coding-agent = {
        package = lib.mkDefault pkgs.llm-agents.pi;
        extraPackages = lib.mkAfter (with pkgs; [
          bun
          nodejs
        ]);
        settings = {
          packages = lib.mkAfter [
            "@dietrichgebert/ponytail"
            "npm:billion-context-pi"
            "npm:pi-caveman"
            "npm:pi-committer"
            "npm:pi-everforest"
            "npm:pi-mcp-adapter"
            "npm:pi-memory"
            "npm:pi-reasonix"
            "npm:pi-simplify"
            "npm:pi-subagents"
            "npm:pi-web-access"
            "npm:pi-zentui"
          ];
          theme = lib.mkDefault "everforest-light-soft/everforest-dark-soft";
        };
      };
    })
  ];
}

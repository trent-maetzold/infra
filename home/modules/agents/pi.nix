{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.programs.pi-coding-agent;

  npmrc = pkgs.writeText "pi-npm-allow-all-scripts.npmrc" ''
    dangerously-allow-all-scripts=true
  '';
in {
  config = lib.mkMerge [
    {programs.pi-coding-agent.enable = lib.mkDefault true;}
    (lib.mkIf cfg.enable {
      home = {
        activation.piNpm = {
          before = [];
          after = ["writeBoundary"];
          data = ''
            run rm -rf "${cfg.configDir}/npm"
            run mkdir -p "${cfg.configDir}/npm"
            run install -m 644 ${npmrc} "${cfg.configDir}/npm/.npmrc"
          '';
        };
        file = {
          ".pi/agent/caveman.json".source = lib.mkDefault ../../config/pi/packages/caveman.json;
          ".pi/agent/zentui.json".source = lib.mkDefault ../../config/pi/packages/zentui.json;
        };
      };
      programs.pi-coding-agent = {
        package = lib.mkDefault pkgs.llm-agents.pi;
        extraPackages = lib.mkAfter (with pkgs; [
          bun
          nodejs
        ]);
        settings = {
          packages = lib.mkAfter [
            "npm:@dietrichgebert/ponytail"
            "npm:@juicesharp/rpiv-ask-user-question"
            "npm:@juicesharp/rpiv-todo"
            "npm:@narumitw/pi-btw"
            "npm:billion-context-pi"
            "npm:pi-advisor-flow"
            "npm:pi-caveman"
            # "npm:pi-committer"
            "npm:pi-everforest"
            "npm:pi-goal-x"
            "npm:pi-reasonix"
            "npm:pi-simplify"
            "npm:pi-subagents"
            "npm:pi-zentui"
          ];
          theme = lib.mkDefault "everforest-light-soft/everforest-dark-soft";
        };
      };
    })
  ];
}

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
      xdg.configFile."ponytail/config.json".text = builtins.toJSON {defaultMode = "ultra";};
      programs.pi-coding-agent = {
        package = lib.mkDefault pkgs.llm-agents.pi;
        extraPackages = lib.mkAfter (with pkgs; [
          bun
          nodejs
        ]);
        settings = {
          packages = lib.mkAfter [
            "npm:@gotgenes/pi-permission-model-judge"
            "npm:@gotgenes/pi-permission-system"
            "npm:@gotgenes/pi-subagents"
            "npm:@gotgenes/pi-subagents-worktrees"

            "npm:@juicesharp/rpiv-advisor"
            "npm:@juicesharp/rpiv-ask-user-question"
            "npm:@juicesharp/rpiv-todo"

            "npm:@narumitw/pi-btw"
            "npm:@narumitw/pi-goal"
            "npm:@narumitw/pi-plan-mode"
            "npm:@narumitw/pi-usage"

            "npm:@dietrichgebert/ponytail"
            "npm:pi-caveman"

            # "npm:pi-committer"
            "npm:pi-lens"
            "npm:pi-simplify"

            "npm:billion-context-pi"
            "npm:pi-reasonix"

            "npm:pi-everforest"
            "npm:pi-zentui"
          ];
          theme = lib.mkDefault "everforest-light-soft/everforest-dark-soft";
        };
      };
    })
  ];
}

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
  config = lib.mkIf cfg.enable {
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
        ".pi/agent/zentui.json".source = lib.mkDefault ../../../config/pi/packages/zentui.json;
      };
    };
    xdg.configFile."ponytail/config.json".text = lib.mkDefault (builtins.toJSON {defaultMode = "ultra";});
    programs.pi-coding-agent = {
      package = lib.mkDefault pkgs.llm-agents.pi;
      extraPackages = lib.mkAfter (with pkgs; [
        bun
        nodejs
      ]);
      settings = {
        packages = lib.mkAfter [
          "npm:@dietrichgebert/ponytail"

          "npm:@gotgenes/pi-permission-model-judge"
          "npm:@gotgenes/pi-permission-system"

          "npm:@juicesharp/rpiv-ask-user-question"
          "npm:@juicesharp/rpiv-btw"
          "npm:@juicesharp/rpiv-todo"

          "npm:@narumitw/pi-usage"

          # "npm:pi-committer"
          "npm:pi-lens"
          "npm:pi-goal-x"
          "npm:pi-simplify"

          "npm:billion-context-pi"
          "npm:pi-reasonix"

          "npm:pi-everforest"
          "npm:pi-zentui"
        ];
        theme = lib.mkDefault "everforest-light-soft/everforest-dark-soft";
      };
    };
  };
}

{config, ...}: {
  flake.modules.homeManager.agents-pi = {
    config,
    pkgs,
    ...
  }: let
    cfg = config.programs.pi-coding-agent;

    npmrc = pkgs.writeText "pi-npm-allow-all-scripts.npmrc" ''
      dangerously-allow-all-scripts=true
    '';
  in {
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
      file.".pi/agent/caveman.json".text = builtins.toJSON {defaultLevel = "lite";};
    };

    xdg.configFile."ponytail/config.json".text = builtins.toJSON {defaultMode = "ultra";};

    programs.pi-coding-agent = {
      enable = true;
      package = pkgs.llm-agents.pi;
      extraPackages = with pkgs; [
        bun
        nodejs
      ];
      settings = {
        packages = [
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
        ];
        theme = "everforest-light-soft/everforest-dark-soft";
      };
    };
  };
  flake.homeModules.default.imports = [config.flake.modules.homeManager.agents-pi];
}

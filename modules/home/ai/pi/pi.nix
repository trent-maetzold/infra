{config, ...}: let
  out = {
    config,
    pkgs,
    ...
  }: let
    cfg = config.programs.pi-coding-agent;

    npmrc = pkgs.writeText "pi-npm-allow-all-scripts.npmrc" ''
      dangerously-allow-all-scripts=true
    '';

    # Merged into a mutable settings.json so pi keeps runtime choices (model, thinking level).
    settings = (pkgs.formats.json {}).generate "pi-coding-agent-settings.json" {
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
  in {
    home = {
      activation = {
        piNpm = {
          before = [];
          after = ["writeBoundary"];
          data = ''
            run rm -rf "${cfg.configDir}/npm"
            run mkdir -p "${cfg.configDir}/npm"
            run install -m 644 ${npmrc} "${cfg.configDir}/npm/.npmrc"
          '';
        };
        piSettings = {
          before = [];
          after = ["writeBoundary"];
          data = ''
            merged=$(${pkgs.jq}/bin/jq -s '.[0] * .[1]' "${cfg.configDir}/settings.json" ${settings} 2>/dev/null || cat ${settings})
            run rm -f "${cfg.configDir}/settings.json"
            run install -Dm 644 /dev/stdin "${cfg.configDir}/settings.json" <<< "$merged"
          '';
        };
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
    };
  };
in {
  # Features
  features.home.ai.pi = out;

  # Home Manager Modules
  flake.homeModules.default.imports = [config.features.home.ai.pi];
}

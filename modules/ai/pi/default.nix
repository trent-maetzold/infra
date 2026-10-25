# pi coding agent with its extension packages, built from packages/pi-plugins.
{config, ...}: let
  modules.homeManager = {
    config,
    pkgs,
    ...
  }: let
    cfg = config.programs.pi-coding-agent;

    # Merged into a mutable settings.json so pi keeps runtime choices (model, thinking level).
    settings = (pkgs.formats.json {}).generate "pi-coding-agent-settings.json" cfg.settings;
  in {
    programs.pi-coding-agent.settings = {
      packages = map (name: "${pkgs.pi-plugins}/node_modules/${name}") [
        "@dietrichgebert/ponytail"
        "@gotgenes/pi-permission-model-judge"
        "@gotgenes/pi-permission-system"
        "@juicesharp/rpiv-ask-user-question"
        "@juicesharp/rpiv-btw"
        "@juicesharp/rpiv-todo"
        "@narumitw/pi-usage"
        "pi-caveman"
        "pi-lens"
        "pi-goal-x"
        "pi-mcp-adapter"
        "pi-simplify"
        "billion-context-pi"
        "pi-reasonix"
        "pi-everforest"
      ];

      theme = "everforest-light-soft/everforest-dark-soft";
    };

    home = {
      activation = {
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

      file = {
        # pi rewrites it, so the activation above owns it, not a store symlink.
        "${cfg.configDir}/settings.json".enable = false;
        ".pi/agent/caveman.json".text = builtins.toJSON {defaultLevel = "lite";};
      };
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

    agents.md.coding-agents = [
      "- `pi`: Pi, minimal coding agent. Headless: `pi -p \"<prompt>\" --model <model> --thinking <off|minimal|low|medium|high|xhigh|max>`."
    ];
  };
in {
  # Flake Modules
  flake.modules.homeManager.pi = modules.homeManager;

  # Home Configuration Modules
  flake.homeModules.default.imports = [config.flake.modules.homeManager.pi];
}

# pi coding agent with its extension packages; its built-in MCP loads the shared MCP servers.
{config, ...}: let
  mergeJson = import ../_lib/make-merged-json.nix;
  mutableSettings = ./_lib/mutable-settings.nix;
in let
  modules.homeManager = {
    config,
    lib,
    pkgs,
    ...
  }: let
    mcp = import ../_lib/make-mcp-json.nix {inherit lib pkgs;} config.programs.mcp.servers;
  in {
    imports = [mutableSettings];

    programs.pi-coding-agent.settings = {
      packages = [
        # Permissions and interaction
        "npm:@gotgenes/pi-permission-model-judge"
        "npm:@gotgenes/pi-permission-system"
        "npm:@juicesharp/rpiv-ask-user-question"
        "npm:@juicesharp/rpiv-btw"
        "npm:@juicesharp/rpiv-todo"
        # Context and cost
        "npm:@narumitw/pi-usage"
        "npm:billion-context-pi"
        "npm:pi-reasonix"
        # Code quality and goals
        "npm:pi-goal-x"
        "npm:pi-lens"
        "npm:pi-simplify"
        # Output style and theme
        "npm:@dietrichgebert/ponytail"
        "npm:pi-caveman"
        "npm:pi-everforest"
      ];

      theme = "everforest-light-soft/everforest-dark-soft";
    };

    # Merged so `/mcp` keeps its enabled and exposure choices.
    home.activation.piMcp = {
      before = [];
      after = ["writeBoundary"];

      data = mergeJson pkgs "${config.programs.pi-coding-agent.configDir}/mcp.json" mcp;
    };

    home.file.".pi/agent/caveman.json".text = builtins.toJSON {defaultLevel = "lite";};
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

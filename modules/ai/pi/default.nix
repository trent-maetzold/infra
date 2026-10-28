# pi coding agent with its extension packages; its built-in MCP loads the gateway.
{
  config,
  jail-nix,
  ...
}: let
  mergeJson = import ../_lib/make-merged-json.nix;
  mutableSettings = ./_lib/mutable-settings.nix;
in let
  modules.homeManager = {
    config,
    pkgs,
    ...
  }: let
    mcp = pkgs.writeText "mcp.json" (builtins.toJSON {
      mcpServers.gateway = {
        type = "http";
        inherit (config.programs.mcp.servers.gateway) url;
      };
    });
    makeJail = import ../_lib/make-jail.nix {inherit config jail-nix pkgs;};
    configDir = "${config.xdg.configHome}/pi/agent";
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

    xdg.configFile."pi/agent/caveman.json".text = builtins.toJSON {defaultLevel = "lite";};
    xdg.configFile."ponytail/config.json".text = builtins.toJSON {defaultMode = "ultra";};

    programs.pi-coding-agent = {
      enable = true;
      inherit configDir;
      # bun and nodejs for packages pi installs, e.g. `npm:@termdraw/pi`.
      package = makeJail "pi" pkgs.llm-agents.pi {
        env.PI_CODING_AGENT_DIR = configDir;
        packages = [pkgs.bun pkgs.nodejs];
      };
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

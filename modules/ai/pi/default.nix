# pi coding agent with its extension packages; its built-in MCP loads the shared MCP servers.
{config, ...}: let
  modules.homeManager = {
    config,
    lib,
    pkgs,
    ...
  }: let
    cfg = config.programs.pi-coding-agent;

    # Deep-merges Nix's JSON over pi's mutable copy, keeping pi's runtime choices.
    merge = name: staticSettings:
      lib.hm.dag.entryAfter ["linkGeneration"] (lib.hm.generators.mkImpureConfigMerger {
        inherit pkgs staticSettings;
        format = "json";
        empty = "{}";
        jqOperation = "$dynamic * $static";
        path = "${cfg.configDir}/${name}";
      });
  in {
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

    home.activation = {
      piSettings = merge "settings.json" ((pkgs.formats.json {}).generate "pi-coding-agent-settings.json" cfg.settings);
      piMcp = merge "mcp.json" config.xdg.configFile."mcp/mcp.json".source;

      # Offline, pi installs them on its next start instead.
      piPackages = lib.hm.dag.entryAfter ["piSettings"] ''
        PATH="${lib.makeBinPath (cfg.extraPackages ++ [pkgs.git])}:$PATH" \
          run ${cfg.package}/bin/pi update --extensions || warnEcho "pi: package install failed"
      '';
    };

    home.file = {
      # pi rewrites it, so piSettings owns it, not a store symlink.
      "${cfg.configDir}/settings.json".enable = false;
      # npm 12 blocks lifecycle scripts (pi-reasonix's build) unless the root package allows them.
      "${cfg.configDir}/npm/.npmrc".text = "dangerously-allow-all-scripts=true\n";
      ".pi/agent/caveman.json".text = builtins.toJSON {defaultLevel = "lite";};
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

# pi coding agent with its extension packages; its built-in MCP loads the shared MCP servers.
{config, ...}: let
  plugins = [
    # Permissions and interaction
    "@gotgenes/pi-permission-model-judge"
    "@gotgenes/pi-permission-system"
    "@juicesharp/rpiv-ask-user-question"
    "@juicesharp/rpiv-btw"
    "@juicesharp/rpiv-todo"
    # Context and cost
    "@narumitw/pi-usage"
    "billion-context-pi"
    "pi-reasonix"
    # Code quality and goals
    "pi-goal-x"
    "pi-lens"
    "pi-simplify"
    # Output style and theme
    "@dietrichgebert/ponytail"
    "pi-caveman"
    "pi-everforest"
  ];

  magpie = import ../_lib/magpie.nix;

  # Unattended agents: everything is allowed but what destroys work or exposes keys.
  permissions = {
    permission = {
      "*" = "allow";

      path = {
        "*" = "allow";
        "*.env" = "deny";
        "*.env.*" = "deny";
        "*.env.example" = "allow";
        "~/.ssh/*" = "deny";
      };

      bash = {
        "*" = "allow";
        "rm -rf *" = "deny";
        "sudo *" = "deny";
      };

      external_directory."*" = "allow";
    };
  };

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
      packages = map (name: pkgs.pi-plugins.extensions.${name}) plugins;
      theme = "everforest-light-soft/everforest-dark-soft";
    };

    home.activation = {
      piSettings = merge "settings.json" ((pkgs.formats.json {}).generate "pi-coding-agent-settings.json" cfg.settings);
      piMcp = merge "mcp.json" config.xdg.configFile."mcp/mcp.json".source;
    };

    home.file = {
      # pi rewrites it, so piSettings owns it, not a store symlink.
      "${cfg.configDir}/settings.json".enable = false;
      ".pi/agent/caveman.json".text = builtins.toJSON {defaultLevel = "lite";};
      ".pi/agent/extensions/pi-permission-system/config.json".text = builtins.toJSON permissions;
    };

    xdg.configFile."ponytail/config.json".text = builtins.toJSON {defaultMode = "ultra";};

    programs.pi-coding-agent = {
      enable = true;
      package = pkgs.llm-agents.pi;
    };

    agents.md.coding-agents = [
      "- `pi`: Pi, minimal coding agent. Headless: `pi -p \"<prompt>\" --model <model> --thinking <off|minimal|low|medium|high|xhigh|max>`."
    ];
  };
in {
  pi = {inherit plugins;};

  # Flake Modules
  flake.modules.homeManager.pi = modules.homeManager;

  # Home Configuration Modules
  flake.homeModules.default.imports = [
    config.flake.modules.homeManager.pi
    {
      home.file.".pi/agent/models.json".text = builtins.toJSON {
        providers.magpie = {
          inherit (magpie) name baseUrl;
          api = "openai-completions";
          apiKey = "$${magpie.apiKeyEnv}";
          models = magpie.makeModels config.flake.lib.makePiModel;
        };
      };
    }
  ];
}

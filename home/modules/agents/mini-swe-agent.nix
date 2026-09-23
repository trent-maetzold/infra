{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.programs.mini-swe-agent;

  yaml = pkgs.formats.yaml {};
  settingsFile = yaml.generate "mini-swe-agent.yaml" cfg.settings;

  # `mini` merges only the configs it is handed with -c, and its default is the
  # built-in mini.yaml on its own. Handing it both keeps the built-in templates
  # and lets `settings` win; a -c passed by hand still wins over this.
  mini = pkgs.symlinkJoin {
    name = "mini-swe-agent-${cfg.package.version}";
    paths = [cfg.package];
    postBuild = ''
      rm "$out/bin/mini"
      ln -s ${cli}/bin/mini "$out/bin/mini"
    '';
  };

  cli = pkgs.writeShellScriptBin "mini" ''
    exec ${lib.getExe cfg.package} -c mini.yaml -c ${settingsFile} "$@"
  '';
in {
  options.programs.mini-swe-agent = {
    enable = lib.mkEnableOption "mini-swe-agent";

    package = lib.mkOption {
      type = lib.types.package;
      default = pkgs.mini-swe-agent;
      description = "mini-swe-agent package the `mini` wrapper runs.";
    };

    model = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      example = "anthropic/claude-sonnet-4-5-20250929";
      description = "Default model, exported as MSWEA_MODEL_NAME. The provider prefix is required.";
    };

    costLimit = lib.mkOption {
      type = lib.types.nullOr lib.types.float;
      default = null;
      example = 3.0;
      description = "Cost limit across all model calls in a session, exported as MSWEA_GLOBAL_COST_LIMIT.";
    };

    callLimit = lib.mkOption {
      type = lib.types.nullOr lib.types.int;
      default = null;
      example = 50;
      description = "Model call limit across a session, exported as MSWEA_GLOBAL_CALL_LIMIT.";
    };

    settings = lib.mkOption {
      type = yaml.type;
      default = {};
      description = ''
        mini.yaml keys for `mini` to run with, merged over the built-in
        mini.yaml: the wrapper passes both to `mini` with `-c`, built-in first,
        so these keys win and the built-in templates survive. A `-c` you pass
        yourself is merged last and wins over both.
      '';
      example = {
        agent = {
          step_limit = 50;
          cost_limit = 3.0;
        };
        environment.env.PAGER = "cat";
        model.model_kwargs.temperature = 0.5;
      };
    };
  };

  config = lib.mkMerge [
    {programs.mini-swe-agent.enable = lib.mkDefault true;}
    (lib.mkIf cfg.enable {
      home.packages = [mini];

      home.sessionVariables =
        {
          MSWEA_CONFIGURED = lib.mkDefault "true";
        }
        // lib.optionalAttrs (cfg.model != null) {
          MSWEA_MODEL_NAME = lib.mkDefault cfg.model;
        }
        // lib.optionalAttrs (cfg.costLimit != null) {
          MSWEA_GLOBAL_COST_LIMIT = lib.mkDefault (toString cfg.costLimit);
        }
        // lib.optionalAttrs (cfg.callLimit != null) {
          MSWEA_GLOBAL_CALL_LIMIT = lib.mkDefault (toString cfg.callLimit);
        };
    })
  ];
}

{
  config,
  lib,
  pkgs,
  ...
}: {
  options.programs.dsh = {
    enable = lib.mkEnableOption "dsh";
    host = lib.mkOption {
      type = lib.types.enum ["127.0.0.1" "0.0.0.0"];
      default = "127.0.0.1";
      description = "Bind host. dsh accepts only loopback or all interfaces.";
    };
    port = lib.mkOption {
      type = lib.types.port;
      default = 3080;
      description = "Listen port.";
    };
    trustedHosts = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [];
      example = ["dsh.tailnet.example.ts.net"];
      description = "Extra authorities the /api browser-trust fence accepts (host or host:port).";
    };
  };

  config = lib.mkMerge [
    {programs.dsh.enable = lib.mkDefault true;}
    (lib.mkIf config.programs.dsh.enable {
      home.packages = lib.mkAfter [pkgs.llm-agents.dsh];
      # mkDefault per leaf, never on the attrset: a whole-value default on a
      # submodule-typed option loses to nested defs from other modules.
      systemd.user.services.dsh = {
        Unit = {
          Description = lib.mkDefault "DeepSeek Harness";
          Wants = ["network.target"];
          After = ["network.target"];
        };
        Service = {
          Type = lib.mkDefault "simple";
          ExecStart = lib.mkDefault (let
            trusted = lib.optionals (config.programs.dsh.trustedHosts != []) (
              ["--trusted-host"] ++ config.programs.dsh.trustedHosts
            );
            args =
              [
                "web"
                "--host"
                config.programs.dsh.host
                "--port"
                (toString config.programs.dsh.port)
              ]
              ++ trusted
              ++ ["--no-open"];
          in "${pkgs.llm-agents.dsh}/bin/dsh ${lib.escapeShellArgs args}");
          WorkingDirectory = lib.mkDefault "%h";
          Restart = lib.mkDefault "on-failure";
          RestartSec = lib.mkDefault 10;
        };
        Install.WantedBy = ["default.target"];
      };
    })
  ];
}

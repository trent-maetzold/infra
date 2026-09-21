{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.programs.pi-coding-agent;

  # pi installs npm: packages from `settings.packages` with `npm install
  # --prefix <configDir>/npm`, so the supervisor only exists once pi has run.
  supervisor = "${cfg.configDir}/npm/node_modules/remote-pi/dist/bin/supervisord.js";

  # Mirrors remote-pi's own systemd template: the supervisor spawns
  # `pi --mode rpc`, so PATH has to resolve the same pi an interactive shell gets.
  supervisorPath = lib.concatStringsSep ":" [
    "${config.home.homeDirectory}/.local/bin"
    "${config.home.homeDirectory}/.nix-profile/bin"
    "/etc/profiles/per-user/${config.home.username}/bin"
    (lib.makeBinPath [pkgs.nodejs])
  ];
in {
  options.programs.pi-coding-agent.remote-pi.enable =
    lib.mkEnableOption "remote-pi (phone remote control and pi daemon fleet)";

  config = lib.mkMerge [
    {programs.pi-coding-agent.enable = lib.mkDefault true;}
    (lib.mkIf config.programs.pi-coding-agent.enable {
      programs.pi-coding-agent = {
        settings = {
          packages = [
            "npm:billion-context-pi"
            "npm:pi-caveman"
            "npm:pi-committer"
            "npm:pi-mcp-adapter"
            "npm:pi-memory"
            "npm:pi-reasonix"
            "npm:pi-simplify"
            "npm:pi-subagents"
            "npm:pi-web-access"
            "npm:pi-zentui"
            "npm:@dietrichgebert/ponytail"
          ];
          theme = lib.mkDefault "dark";
        };
        extraPackages = with pkgs; [
          nodejs
          bun
        ];
      };
      home.file.".pi/agent/zentui.json".source = lib.mkDefault ../../config/pi/packages/zentui.json;
      home.file.".pi/agent/caveman.json".source = lib.mkDefault ../../config/pi/packages/caveman.json;
    })
    (lib.mkIf config.programs.pi-coding-agent.remote-pi.enable {
      programs.pi-coding-agent.settings.packages = ["npm:remote-pi"];

      # Same unit `remote-pi install` writes, so the CLI's status/uninstall
      # agree with this one — don't run both.
      systemd.user.services.remote-pi-supervisord = {
        Unit = {
          Description = lib.mkDefault "Remote Pi daemon supervisor";
          Documentation = lib.mkAfter ["https://remote-pi.jacobmoura.work"];
          After = lib.mkAfter ["default.target"];
          ConditionPathExists = lib.mkAfter [supervisor];
        };
        Service = {
          Type = lib.mkDefault "simple";
          ExecStart = lib.mkDefault "${pkgs.nodejs}/bin/node ${supervisor}";
          Environment = lib.mkAfter [
            "HOME=${config.home.homeDirectory}"
            "PATH=${supervisorPath}"
            "PI_CODING_AGENT_DIR=${cfg.configDir}"
          ];
          Restart = lib.mkDefault "on-failure";
          RestartSec = lib.mkDefault 5;
          StandardOutput = lib.mkDefault "journal";
          StandardError = lib.mkDefault "journal";
        };
        Install.WantedBy = lib.mkAfter ["default.target"];
      };
    })
  ];
}

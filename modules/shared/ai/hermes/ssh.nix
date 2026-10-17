# Hermes on `config.vars.hermes` over SSH: `hermes` runs the remote TUI, since
# the TUI can't attach remotely, and a user service tunnels the remote backend
# to localhost:9119 for hermes-desktop and the dashboard. Excludes hermes-tui.
let
  home = {
    config,
    pkgs,
    ...
  }: let
    ssh = "${pkgs.openssh}/bin/ssh";
    host = config.vars.hermes;
  in {
    home.packages = [(pkgs.writeShellScriptBin "hermes" ''exec ${ssh} -t ${host} hermes "$@"'')];

    systemd.user.services.hermes-tunnel = {
      Unit.Description = "Hermes backend tunnel to ${host}";
      Install.WantedBy = ["default.target"];

      Service = {
        ExecStart = "${ssh} -NT -o ExitOnForwardFailure=yes -o ServerAliveInterval=30 -L 9119:127.0.0.1:9119 ${host}";
        Restart = "always";
        RestartSec = 10;
      };
    };
  };
in {
  # Features
  features.home.ai.hermes-ssh = home;
}

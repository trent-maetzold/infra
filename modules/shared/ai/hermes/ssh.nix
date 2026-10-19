# Hermes on `config.vars.hermes` over SSH: `hermes` runs the remote TUI, since
# the TUI can't attach remotely, and a user service tunnels the remote backend
# to the local backend endpoint for hermes-desktop and the dashboard. Excludes hermes-tui
# and hermes.
{config, ...}: let
  backend = config.my.endpoints.hermes-backend;

  home = {
    config,
    pkgs,
    ...
  }: let
    ssh = "${pkgs.openssh}/bin/ssh";
    host = config.vars.hermes;
  in {
    home.packages = [
      (pkgs.writeShellScriptBin "hermes" ''exec ${ssh} -t ${host} hermes "$@"'')
      (pkgs.writeShellScriptBin "hermes-session-token" "exec ${ssh} ${host} cat /var/lib/hermes/.hermes/session-token")
    ];

    systemd.user.services.hermes-tunnel = {
      Unit.Description = "Hermes backend tunnel to ${host}";
      Install.WantedBy = ["default.target"];

      Service = {
        ExecStart = "${ssh} -NT -o ExitOnForwardFailure=yes -o ServerAliveInterval=30 -L ${toString backend.port}:${backend.host}:${toString backend.port} ${host}";
        Restart = "always";
        RestartSec = 10;
      };
    };
  };
in {
  # Features
  features.home.ai.hermes-ssh = home;
}

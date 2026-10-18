# Hermes Desktop on the backend at localhost:9119, the local base's or the
# hermes-ssh tunnel's; either provides `hermes-session-token`.
{hermes-agent, ...}: let
  home = {pkgs, ...}: {
    home.packages = [
      (hermes-agent.packages.${pkgs.stdenv.hostPlatform.system}.default.hermesDesktop.override {
        extraEnv.HERMES_DESKTOP_REMOTE_URL = "http://127.0.0.1:9119";
        extraRun = [''HERMES_DESKTOP_REMOTE_TOKEN="$(hermes-session-token)"; export HERMES_DESKTOP_REMOTE_TOKEN''];
      })
    ];
  };
in {
  # Features
  features.home.ai.hermes-desktop = home;
}

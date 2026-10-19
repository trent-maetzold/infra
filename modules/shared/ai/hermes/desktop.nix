# Hermes Desktop on the backend at the hermes backend, the local base's or the
# hermes-ssh tunnel's; either provides `hermes-session-token`.
{
  config,
  hermes-agent,
  ...
}: let
  backend = config.my.endpoints.hermes-backend;

  home = {pkgs, ...}: {
    home.packages = [
      (hermes-agent.packages.${pkgs.stdenv.hostPlatform.system}.default.hermesDesktop.override {
        extraEnv.HERMES_DESKTOP_REMOTE_URL = backend.url;
        extraRun = [''HERMES_DESKTOP_REMOTE_TOKEN="$(hermes-session-token)"; export HERMES_DESKTOP_REMOTE_TOKEN''];
      })
    ];
  };
in {
  # Features
  features.home.ai.hermes-desktop = home;
}

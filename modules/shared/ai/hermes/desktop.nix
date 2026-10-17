# Hermes Desktop on the backend at localhost:9119: the local base's, or the
# hermes-ssh tunnel's. On WSL the Windows app connects instead, so
# `hermes-desktop` prints the URL and token to enter in it.
{hermes-agent, ...}: let
  home = {
    config,
    osConfig ? {},
    pkgs,
    ...
  }: let
    url = "http://127.0.0.1:9119";
    remote = config.systemd.user.services ? hermes-tunnel;
    local = osConfig.services.hermes-agent or config.services.hermes-agent;

    token =
      if remote
      then "${pkgs.openssh}/bin/ssh ${config.vars.hermes} cat /var/lib/hermes/.hermes/session-token"
      else "cat ${local.backend.sessionTokenFile}";

    app = hermes-agent.packages.${pkgs.stdenv.hostPlatform.system}.default.hermesDesktop.override {
      extraEnv.HERMES_DESKTOP_REMOTE_URL = url;
      extraRun = [''HERMES_DESKTOP_REMOTE_TOKEN="$(${token})"; export HERMES_DESKTOP_REMOTE_TOKEN''];
    };

    connect = pkgs.writeShellScriptBin "hermes-desktop" ''
      echo "Remote gateway URL: ${url}"
      echo "Token: $(${token})"
    '';
  in {
    home.packages = [
      (
        if osConfig.wsl.enable or false
        then connect
        else app
      )
    ];
  };
in {
  # Features
  features.home.ai.hermes-desktop = home;
}

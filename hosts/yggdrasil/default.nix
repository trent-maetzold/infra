{
  config,
  pkgs,
  ...
}: {
  imports = [
    ./boot.nix
    ./disk-config.nix
    ./persist.nix
    ./services/dockhand.nix
    ./services/traefik.nix
    ./vms/mimir.nix
  ];

  hardware.facter.reportPath = ./facter.json;

  services = {
    hermes-agent.environmentFiles = ["/var/lib/secrets/deepseek-env" "/var/lib/secrets/opencode-env"];
    hermes-webui.environmentFiles = ["/var/lib/secrets/hermes-webui-env"];
  };

  # Claude Code signs in with the `claude setup-token` token.
  home-manager.users.tm.programs.claude-code.package = pkgs.symlinkJoin {
    name = "claude-code";
    paths = [pkgs.llm-agents.claude-code];
    nativeBuildInputs = [pkgs.makeWrapper];
    postBuild = "wrapProgram $out/bin/claude --run 'export CLAUDE_CODE_OAUTH_TOKEN=$(< /var/lib/secrets/claude-code-oauth-token)'";
  };

  # hermes-webui stays on loopback; serve proxies it to the tailnet for Hermex.
  systemd.services.tailscale-serve-hermes-webui = let
    port = toString config.services.hermes-webui.port;
    serve = "${config.services.tailscale.package}/bin/tailscale serve --http=${port}";
  in {
    after = ["tailscaled.service" "hermes-webui.service"];
    wants = ["tailscaled.service"];
    wantedBy = ["multi-user.target"];

    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStart = "${serve} --bg http://127.0.0.1:${port}";
      ExecStop = "${serve} off";
      Restart = "on-failure";
      RestartSec = 10;
    };
  };
}

{config, ...}: {
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
    hermes-agent.environmentFiles = ["/var/lib/secrets/opencode-env"];
    hermes-webui.environmentFiles = ["/var/lib/secrets/hermes-webui-env"];
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

{
  imports = [
    ./boot.nix
    ./disk-config.nix
    ./persist.nix
    ./services/dockhand.nix
    ./services/traefik.nix
    ./vms/mimir.nix
  ];

  hardware.facter.reportPath = ./facter.json;

  # hermes-webui on the tailnet for Hermex, behind its password.
  networking.firewall.interfaces.tailscale0.allowedTCPPorts = [8787];

  services = {
    hermes-agent.environmentFiles = ["/var/lib/secrets/opencode-env"];

    hermes-webui = {
      host = "0.0.0.0";
      environmentFiles = ["/var/lib/secrets/hermes-webui-env"];
    };
  };
}

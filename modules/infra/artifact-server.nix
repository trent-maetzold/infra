# Artifact Server's local-owner mode on loopback; MCP reaches yggdrasil over SSH.
{
  config,
  lib,
  quadlet-nix,
  ...
}: let
  sshHost = "yggdrasil";
  modules.nixos = {
    config,
    lib,
    ...
  }: {
    imports = [quadlet-nix.nixosModules.quadlet];
    virtualisation.podman.enable = true;

    virtualisation.quadlet = {
      volumes.artifact-server = {};
      containers.artifact-server = {
        # Node is PID 1 upstream, so give it time to checkpoint SQLite on stop.
        serviceConfig = {
          KillSignal = "SIGTERM";
          Restart = "always";
          TimeoutStopSec = "30s";
        };
        containerConfig = {
          name = "artifact-server";
          image = lib.mkDefault "ghcr.io/plannotator/artifact-server:v0.1.2@sha256:e832267831dddd905d158aeeb6b331ef314c7d4737c8769d7bd335b91bd43055";
          # Local-owner mode binds only loopback, including inside a container,
          # so the host netns is the only way to reach it; nothing else on
          # 127.0.0.1 is exposed by its port 8788.
          networks = ["host"];
          exec = lib.mkDefault "start --managed --data /var/lib/artifact-server/data --port 8788";
          volumes = ["${config.virtualisation.quadlet.volumes.artifact-server.ref}:/var/lib/artifact-server:U"];
        };
      };
    };
  };

  hosts.yggdrasil.persistence.dirs."/var/lib/containers/storage/volumes".snapshots = true;
in {
  # Flake Modules
  flake.modules.nixos.artifact-server = modules.nixos;

  # NixOS Configuration Modules
  flake.nixosModules.yggdrasil.imports = [
    config.flake.modules.nixos.artifact-server
    config.flake.modules.nixos.quadlet
    hosts.yggdrasil
  ];

  # Home Configuration Modules
  flake.homeModules.tm.imports = [
    ({pkgs, ...}: {
      programs.mcp.servers.artifact-server = {
        command = "${pkgs.openssh}/bin/ssh";
        args = ["-T" "-o" "BatchMode=yes" sshHost "sudo" "-n" "podman" "exec" "-i" "artifact-server" "node" "dist/cli/main.js" "mcp" "--data" "/var/lib/artifact-server/data"];
      };
    })
  ];
}

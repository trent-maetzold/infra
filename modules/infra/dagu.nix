# Dagu workflow scheduler with built-in auth, persistent state, and HTTP MCP.
{
  config,
  quadlet-nix,
  ...
}: let
  port = 8080;
  modules.nixos = {
    config,
    lib,
    ...
  }: {
    imports = [quadlet-nix.nixosModules.quadlet];
    virtualisation.podman.enable = true;

    virtualisation.quadlet = {
      volumes.dagu = {};
      containers.dagu = {
        serviceConfig.Restart = "always";
        containerConfig = {
          name = "dagu";
          image = lib.mkDefault "ghcr.io/dagucloud/dagu:2.25.2";
          volumes = ["${config.virtualisation.quadlet.volumes.dagu.ref}:/var/lib/dagu"];
          publishPorts = lib.mkDefault ["127.0.0.1:${toString port}:${toString port}"];
          environments = {
            DAGU_HOST = "0.0.0.0";
            DAGU_PORT = toString port;
            DAGU_AUTH_MODE = "builtin";
            DAGU_DAGS_DIR = "/var/lib/dagu/dags";
          };
        };
      };
    };
  };

  route = config.flake.lib.makeServiceRoute {
    hostname = "dagu.ts.trkm.io";
    ip = config.hosts.yggdrasil.ips.tailnet;
    inherit port;
  };

  hosts.yggdrasil = {
    persistence.dirs."/var/lib/containers/storage/volumes".snapshots = true;
    virtualisation.quadlet.containers.dagu.containerConfig.publishPorts = ["${route.endpoint.ip}:${toString port}:${toString port}"];
  };
in {
  # Flake Modules
  flake.modules.nixos.dagu = modules.nixos;

  # NixOS Configuration Modules
  flake.nixosModules.yggdrasil.imports = [
    config.flake.modules.nixos.dagu
    config.flake.modules.nixos.quadlet
    hosts.yggdrasil
  ];

  # Home Configuration Modules
  flake.homeModules.tm.programs.mcp.servers.dagu = {
    url = "https://${route.hostname}/mcp";
    headers.Authorization = "Bearer \${DAGU_API_KEY}";
  };

  # Routes
  routes.dagu = route;
}

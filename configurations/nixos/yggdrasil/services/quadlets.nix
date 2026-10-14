{
  config,
  quadlet-nix,
  ...
}: {
  flake.nixos.yggdrasil.quadlets = {
    boot.kernel.sysctl."net.ipv4.ip_unprivileged_port_start" = 443;

    home-manager.users.podman = {
      imports = [
        quadlet-nix.homeManagerModules.quadlet
        config.flake.home.yggdrasil.dockhand
        config.flake.home.yggdrasil.traefik
      ];

      home = {
        username = "podman";
        homeDirectory = "/var/lib/podman";
        stateVersion = "26.11";
      };

      virtualisation.quadlet.autoEscape = true;
    };

    systemd.tmpfiles.rules = [
      "d /var/lib/podman 0700 podman podman -"
    ];

    users = {
      groups.podman = {};
      users.podman = {
        isSystemUser = true;
        group = "podman";
        home = "/var/lib/podman";
        createHome = true;
        linger = true;
        autoSubUidGidRange = true;
      };
    };

    virtualisation = {
      podman.enable = true;
      containers.storage.settings.storage.rootless_storage_path = "/var/lib/podman/storage";
    };
  };
}

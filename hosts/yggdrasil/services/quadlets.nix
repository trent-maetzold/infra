{quadlet-nix, ...}: {
  boot.kernel.sysctl."net.ipv4.ip_unprivileged_port_start" = 443;

  disko.devices.zpool.tank.datasets.podman = {
    type = "zfs_fs";
    mountpoint = "/var/lib/podman";
    options.mountpoint = "legacy";
  };

  home-manager.users.podman = {
    imports = [
      quadlet-nix.homeManagerModules.quadlet
      ./dockhand.nix
      ./traefik.nix
    ];

    home = {
      username = "podman";
      homeDirectory = "/var/lib/podman";
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

  virtualisation.podman.enable = true;
}

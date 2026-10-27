# Distrobox with `bx`, an Arch container for builds needing distro packages, and
# `gbx`, a uv Debian container able to build psycopg2 and gssapi.
{config, ...}: let
  modules.homeManager = {
    config,
    lib,
    pkgs,
    ...
  }: let
    makeDistroboxWrapper = import ./_lib/make-distrobox-wrapper.nix {inherit pkgs;};
  in {
    agents.md.tools = [
      "- `bx`: distrobox for builds that need distro packages or a mutable distro: `bx <cmd>`."
      "- `gbx`: Debian distrobox with uv, libpq, krb5 and Python headers (psycopg2, gssapi): `gbx <cmd>`."
    ];

    home.file = {
      ".local/bin/bx" = makeDistroboxWrapper "bx";
      ".local/bin/gbx" = makeDistroboxWrapper "gbx";
      ".local/bin/distrobox-export".source = "${pkgs.distrobox}/bin/distrobox-export";
      ".local/bin/distrobox-host-exec".source = "${pkgs.distrobox}/bin/distrobox-host-exec";
    };

    # Pre-pulled; the wrappers create the containers on first use.
    services.podman.images = lib.mapAttrs (_: c: {inherit (c) image;}) config.programs.distrobox.containers;

    programs.distrobox = {
      enable = true;
      # Its unit can't find a home-manager podman.
      enableSystemdUnit = false;

      containers.bx = {
        image = lib.mkDefault "archlinux:base-devel";
        additional_packages = lib.mkDefault "zsh";
        entry = true;
        init_hooks = ["usermod -s /usr/bin/zsh ${config.home.username}"];
      };

      containers.gbx = {
        image = "ghcr.io/astral-sh/uv:trixie";
        additional_packages = "libkrb5-dev libpq-dev python3-dev zsh";
        entry = true;
        init_hooks = ["usermod -s /usr/bin/zsh ${config.home.username}"];
      };

      settings = {
        container_manager = "podman";
        container_always_pull = "1";
      };
    };
  };
in {
  # Flake Modules
  flake.modules.homeManager.distrobox = modules.homeManager;

  # Home Configuration Modules
  flake.homeModules.default.imports = [config.flake.modules.homeManager.distrobox];
}

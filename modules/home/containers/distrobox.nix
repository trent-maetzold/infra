{config, ...}: let
  out = {
    config,
    lib,
    pkgs,
    ...
  }: let
    wrappers = ["bx"];
  in {
    config = lib.mkMerge [
      {
        agents.md.tools = ["- `bx`: distrobox for builds that need distro packages or a mutable distro: `bx <cmd>`."];

        home.file = {
          ".local/bin/distrobox-export".source = "${pkgs.distrobox}/bin/distrobox-export";
          ".local/bin/distrobox-host-exec".source = "${pkgs.distrobox}/bin/distrobox-host-exec";
        };
        programs.distrobox = {
          enable = true;
          containers = {
            bx = {
              image = lib.mkDefault "archlinux:base-devel";
              additional_packages = lib.mkDefault "zsh";
              entry = true;
              init_hooks = ["usermod -s /usr/bin/zsh ${config.home.username}"];
            };
          };
          settings = {
            container_manager = "podman";
            container_always_pull = "1";
          };
        };
      }

      {
        home.file = lib.mapAttrs' (name: cont: {
          name = ".local/bin/${name}";
          value = {
            executable = true;
            text = ''
              #!${pkgs.bash}/bin/bash

              # Self-heal: home-manager records its hash even when create fails.
              if ! distrobox list 2>/dev/null | awk -F'|' 'NR>1 {gsub(/[[:space:]]/, "", $2); if ($2 == "${name}") found=1} END {exit !found}'; then
                distrobox-assemble create --file "$HOME/.config/distrobox/containers.ini"
              fi

              if [ $# -gt 0 ]; then
                distrobox enter ${name} -- "$@"
              else
                distrobox enter ${name}
              fi
            '';
          };
        }) (lib.genAttrs wrappers lib.id);
      }
    ];
  };
in {
  # Features
  features.home.containers.distrobox = out;

  # Home Manager Modules
  flake.homeModules.default.imports = [config.features.home.containers.distrobox];
}

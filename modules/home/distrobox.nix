{config, ...}: {
  flake.modules.homeManager.distrobox = {
    config,
    lib,
    pkgs,
    ...
  }: let
    containers = config.programs.distrobox.containers;
  in {
    config = lib.mkMerge [
      {
        home.file = {
          ".local/bin/distrobox-export".source = "${pkgs.distrobox}/bin/distrobox-export";
          ".local/bin/distrobox-host-exec".source = "${pkgs.distrobox}/bin/distrobox-host-exec";
        };
        programs.distrobox = {
          enable = true;
          containers = {
            bx = {
              image = "archlinux:base-devel";
              additional_packages = "zsh";
              entry = true;
              init_hooks = ["usermod -s /usr/bin/zsh ${config.home.username}"];
              make_wrapper = true;
            };
          };
          settings = {
            container_manager = "podman";
            container_always_pull = "1";
          };
        };
      }

      (lib.mkIf (containers != {}) {
        xdg.configFile."distrobox/containers.ini".source = lib.mkForce (
          (pkgs.formats.ini {listsAsDuplicateKeys = true;}).generate
          "distrobox-containers.ini"
          (lib.mapAttrs (_: v: lib.removeAttrs v ["make_wrapper"]) containers)
        );

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
        }) (lib.filterAttrs (_: cont: cont.make_wrapper or false) containers);
      })
    ];
  };
  flake.homeModules.default.imports = [config.flake.modules.homeManager.distrobox];
}

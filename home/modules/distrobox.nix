{
  config,
  lib,
  pkgs,
  ...
}: let
  containers = config.programs.distrobox.containers;
in {
  config = lib.mkMerge [
    {programs.distrobox.enable = lib.mkDefault true;}
    (lib.mkIf config.programs.distrobox.enable (lib.mkMerge [
      {
        home = {
          sessionPath = lib.mkDefault ["$HOME/.local/bin"];
          file = {
            ".local/bin/distrobox-export".source = lib.mkDefault "${pkgs.distrobox}/bin/distrobox-export";
            ".local/bin/distrobox-host-exec".source = lib.mkDefault "${pkgs.distrobox}/bin/distrobox-host-exec";
          };
        };
        programs.distrobox = {
          containers = {
            bx = {
              image = lib.mkDefault "archlinux:base-devel";
              additional_packages = lib.mkDefault "zsh";
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
        home.file = lib.mkDefault (lib.mapAttrs' (name: cont: {
          name = ".local/bin/${name}";
          value = {
            executable = true;
            text = ''
              #!${pkgs.bash}/bin/bash

              # Generated for the "${name}" container (make_wrapper = true).
              # The home-manager systemd unit only creates containers when containers.ini
              # changes, and it records the hash even when creation fails. Self-heal here:
              # distrobox-assemble create is a no-op if the container already exists.

              if ! distrobox list 2>/dev/null | awk -F'|' 'NR>1 {gsub(/[[:space:]]/, "", $2); if ($2 == "${name}") found=1} END {exit !found}'; then
                distrobox-assemble create --file "$HOME/.config/distrobox/containers.ini"
              fi

              if [ $# -gt 0 ]; then
                # distrobox-enter requires "--" before the command, otherwise it
                # treats the first argument as the container name.
                distrobox enter ${name} -- "$@"
              else
                distrobox enter ${name}
              fi
            '';
          };
        }) (lib.filterAttrs (_: cont: cont.make_wrapper or false) containers));
      })
    ]))
  ];
}

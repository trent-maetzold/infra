# A coding agent in bubblewrap: host network (for the loopback MCP gateway), the
# working directory, the store and user profile read-only, and its `state` dirs
# read-write; `env` dirs are state too, `packages` go on its PATH. No /run/user, ~/.ssh, rbw or rest of
# $HOME; no_new_privs stops sudo.
{
  flake.lib.makeAgentJail = {
    config,
    jail-nix,
    pkgs,
  }: name: package: {
    env ? {},
    packages ? [],
    state ? [],
  }: let
    jail = jail-nix.lib.init pkgs;
  in
    jail name (pkgs.lib.getExe' package name) (with jail.combinators;
      [
        network
        no-new-session
        mount-cwd
        # The repo's git dir (outside $PWD in a worktree) with read-only hooks and
        # config, so an agent can't plant code git runs outside the jail.
        (add-runtime ''
          if GIT_DIR=$(${pkgs.lib.getExe pkgs.git} rev-parse --path-format=absolute --git-common-dir 2>/dev/null); then
            RUNTIME_ARGS+=(--bind "$GIT_DIR" "$GIT_DIR")
            for p in "$GIT_DIR/hooks" "$GIT_DIR/config"; do
              if [ -e "$p" ]; then RUNTIME_ARGS+=(--ro-bind "$p" "$p"); fi
            done
          fi
        '')
        (readonly "/nix/store")
        (try-readwrite "/nix/var/nix/daemon-socket")
        (try-readonly "/etc/nix")
        (try-readonly "/etc/static")
        (try-readonly "/run/current-system")
        (try-readonly config.home.profileDirectory)
        (add-path "/run/current-system/sw/bin")
        (add-path "${config.home.profileDirectory}/bin")
        (try-readonly "${config.xdg.configHome}/git")
        (try-readonly "${config.home.homeDirectory}/.agents/skills")
        (try-fwd-env "COLORTERM")
        (try-fwd-env "LOCALE_ARCHIVE")
        (add-pkg-deps packages)
      ]
      ++ pkgs.lib.mapAttrsToList set-env env
      ++ map (dir:
        compose [
          (add-runtime "mkdir -p ${pkgs.lib.escapeShellArg dir}")
          (readwrite dir)
        ])
      (builtins.attrValues env ++ state))
    # Home Manager modules gate features on the package version.
    // {inherit (package) version;};
}

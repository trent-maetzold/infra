# HM module that merges pi's settings into a mutable settings.json and installs its packages.
{
  config,
  pkgs,
  ...
}: let
  cfg = config.programs.pi-coding-agent;

  npmrc = pkgs.writeText "pi-npm-allow-all-scripts.npmrc" ''
    dangerously-allow-all-scripts=true
  '';

  makeMergedJson = import ./make-merged-json.nix {inherit pkgs;};
  settings = (pkgs.formats.json {}).generate "pi-coding-agent-settings.json" cfg.settings;
in {
  home = {
    activation = {
      piNpm = {
        before = [];
        after = ["writeBoundary"];

        data = ''
          run rm -rf "${cfg.configDir}/npm"
          run mkdir -p "${cfg.configDir}/npm"
          run install -m 644 ${npmrc} "${cfg.configDir}/npm/.npmrc"
        '';
      };

      # Merged so pi keeps runtime choices (model, thinking level).
      piSettings = {
        before = [];
        after = ["piNpm"];

        data = makeMergedJson "${cfg.configDir}/settings.json" settings;
      };

      # Offline, pi installs them on its next start instead.
      piPackages = {
        before = [];
        after = ["piSettings"];

        data = ''
          PATH="${pkgs.lib.makeBinPath (cfg.extraPackages ++ [pkgs.git])}:$PATH" \
            run ${cfg.package}/bin/pi update --extensions || warnEcho "pi: package install failed"
        '';
      };
    };

    # pi rewrites it, so the activation above owns it, not a store symlink.
    file."${cfg.configDir}/settings.json".enable = false;
  };
}

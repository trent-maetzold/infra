{config, ...}: let
  out = {
    lib,
    pkgs,
    ...
  }: let
    profile = "$HOME/.dsh/profiles/tui";
    version = "0.1.2";

    packageJson = pkgs.writeText "dsh-profile-tui.json" (builtins.toJSON {
      name = "dsh-profile-tui";
      private = true;
      dependencies."@dsh-tui/dsh-tui" = version;
      dsh.profile.bundles = [
        "@deepseek-ai/dsh-base"
        "@dsh-tui/dsh-tui"
      ];
    });

    pnpmWorkspace = pkgs.writeText "dsh-tui-pnpm-workspace.yaml" ''
      packages:
        - .

      nodeLinker: hoisted
      autoInstallPeers: false
    '';

    # Seeded once: the TUI and dsh's settings forms write the profile, so it
    # stays the user's after the first activation. Install the bundle with
    # `dsh plugin --profile tui add @dsh-tui/dsh-tui` before the first run.
    patch = pkgs.writeText "dsh-tui-cordis.patch.yml" ''
      # Seeded by asgard; edit freely from here on.

      # Interactive: approvals stay on so the dialog can answer them.
      - id: approval
        config:
          policy: ask

      - id: sandbox-policy
        config:
          mode: workspace-write
          workspaceRoot: !!js process.cwd()

      # Session logs are sent to DeepSeek with the next request by default.
      - id: session-log-deepseek
        config:
          enabled: false

      - id: tui
        config:
          showReasoning: true
          maxToolOutputLines: 12
          title: dsh
          theme:
            color: true
            truecolor: true
    '';
  in {
    home.activation.dshTuiProfile = lib.hm.dag.entryAfter ["writeBoundary"] ''
      run mkdir -p ${profile}

      if [ ! -e ${profile}/package.json ]; then
        run install -m 0644 ${packageJson} ${profile}/package.json
      fi

      if [ ! -e ${profile}/pnpm-workspace.yaml ]; then
        run install -m 0644 ${pnpmWorkspace} ${profile}/pnpm-workspace.yaml
      fi

      if [ ! -e ${profile}/cordis.patch.yml ]; then
        run install -m 0644 ${patch} ${profile}/cordis.patch.yml
      fi

      if [ ! -e ${profile}/node_modules/@dsh-tui/dsh-tui ]; then
        echo 'dsh-tui: run dsh plugin --profile tui add @dsh-tui/dsh-tui once' >&2
      fi
    '';

    # The update check is a registry request the TUI does not need.
    home.sessionVariables.DSH_TUI_UPDATE_CHECK = "0";

    agents.md.coding-agents = [
      "- `dsh-tui`: community TUI for dsh, interactive only: `dsh --profile tui`; install its bundle once with `dsh plugin --profile tui add @dsh-tui/dsh-tui`."
    ];
  };
in {
  # Features
  features.home.ai.dsh-tui = out;

  # Home Manager Modules
  flake.homeModules.dsh-tui.imports = [config.features.home.ai.dsh-tui];
}

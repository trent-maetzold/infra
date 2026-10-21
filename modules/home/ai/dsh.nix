{config, ...}: let
  out = {
    lib,
    pkgs,
    ...
  }: let
    profile = "$HOME/.dsh/profiles/headless";

    packageJson = pkgs.writeText "dsh-profile-headless.json" (builtins.toJSON {
      name = "dsh-profile-headless";
      private = true;
      dependencies = {};
      dsh.profile.bundles = [
        "@deepseek-ai/dsh-base"
        "@deepseek-ai/dsh-headless"
      ];
    });

    pnpmWorkspace = pkgs.writeText "dsh-pnpm-workspace.yaml" ''
      packages:
        - .

      nodeLinker: hoisted
      autoInstallPeers: false
    '';

    # Seeded once: dsh and its settings forms write this file, so it stays the
    # user's after the first activation.
    patch = pkgs.writeText "dsh-cordis.patch.yml" ''
      # Seeded by asgard; edit freely from here on.

      # An unattended run cannot answer approval prompts.
      - id: approval
        config:
          policy: never

      # Session logs are sent to DeepSeek with the next request by default.
      - id: session-log-deepseek
        config:
          enabled: false

      # Titles cost a model call the one-shot result never shows.
      - id: session-title-llm
        disabled: true
    '';
  in {
    home.packages = [pkgs.llm-agents.dsh];

    # Any non-empty value opts the process out of OTel delivery.
    home.sessionVariables.DSH_TELEMETRY_DISABLED = "1";

    home.activation.dshHeadlessProfile = lib.hm.dag.entryAfter ["writeBoundary"] ''
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
    '';

    agents.md.coding-agents = [
      "- `dsh`: DeepSeek's agent harness. Headless: `dsh headless \"<task>\"`; the profile never asks, confines writes to the workspace, withholds session logs, and takes the model from `agent-default-model`."
    ];
  };
in {
  # Features
  features.home.ai.dsh = out;

  # Home Manager Modules
  flake.homeModules.dsh.imports = [config.features.home.ai.dsh];
}

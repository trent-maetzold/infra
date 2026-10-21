{config, ...}: let
  out = {
    config,
    lib,
    pkgs,
    ...
  }: let
    home = config.home.homeDirectory;

    settings = {
      version = 1;
      # Vim keys in the prompt, matching the rest of the editor.
      editor.vimMode = true;
      # Deterministic approvals: allow what is allowed, deny what is denied.
      approvalMode = "allowlist";
      sandbox = {
        mode = "enabled";
        readBoundary = "workspace";
      };
      attribution = {
        attributeCommitsToAgent = false;
        attributePRsToAgent = false;
      };
      permissions = {
        allow = ["Read(**)"];
        deny = [
          "Shell(git:push*)"
          "Shell(sudo)"
          "Shell(rm:-rf*)"
          "Shell(rm:-fr*)"
          "Shell(dd)"
          "Shell(mkfs)"
          "Shell(chmod:777*)"
          "Read(.env*)"
          "Read(**/.env*)"
          "Read(**/secrets/**)"
          "Read(**/*.age)"
          "Read(**/*.key)"
          "Read(**/*.pem)"
          "Read(${home}/.ssh/**)"
          "Read(${home}/.aws/**)"
          "Read(${home}/.gnupg/**)"
          "Read(${home}/.dsh/.credentials.yaml)"
          "Read(${home}/.codex/auth.json)"
          "Read(${home}/.claude/.credentials.json)"
          "Write(**/.env*)"
          "Write(**/secrets/**)"
          "Write(${home}/.ssh/**)"
          "Write(${home}/.aws/**)"
        ];
      };
    };

    # The CLI rewrites cli-config.json as it runs, so merge into the existing
    # file instead of linking a read-only copy of it.
    mutableConfig = lib.hm.generators.mkImpureConfigMerger {
      inherit pkgs;
      format = "json";
      empty = "{}";
      jqOperation = "$dynamic * $static";
      path = "${home}/.cursor/cli-config.json";
      staticSettings = (pkgs.formats.json {}).generate "cursor-cli-config" settings;
      mode = "600";
    };

    formatNix = pkgs.writeShellScript "format-nix" ''
      file=$(jq -r '.file_path // empty')
      case "$file" in *.nix) exec ${lib.getExe pkgs.alejandra} "$file" ;; esac
    '';
  in {
    home.packages = [pkgs.llm-agents.cursor-agent];

    home.file = {
      ".cursor/sandbox.json".text = builtins.toJSON {
        type = "workspace_readwrite";
        networkPolicy = {
          # No network unless the build needs one of these registries.
          default = "deny";
          allow = [
            "cache.nixos.org"
            "github.com"
            "codeberg.org"
            "registry.npmjs.org"
            "pypi.org"
            "files.pythonhosted.org"
          ];
        };
      };

      ".cursor/hooks.json".text = builtins.toJSON {
        version = 1;
        hooks.afterFileEdit = [{command = "./hooks/format-nix";}];
      };

      ".cursor/hooks/format-nix" = {
        text = formatNix;
        executable = true;
      };
    };

    home.activation.cursorCliConfig = lib.hm.dag.entryAfter ["linkGeneration"] mutableConfig;

    agents.md.coding-agents = [
      "- `cursor-cli`: Cursor CLI, command `cursor-agent`. Headless: `cursor-agent -p --force --model <model[:variant]> \"<prompt>\"`; deny rules still apply under `--force`, and the sandbox keeps writes in the workspace with only registry hosts reachable."
    ];
  };
in {
  # Features
  features.home.ai.cursor-cli = out;

  # Home Manager Modules
  flake.homeModules.cursor-cli.imports = [config.features.home.ai.cursor-cli];
}

{config, ...}: let
  out = {
    config,
    lib,
    pkgs,
    ...
  }: let
    # apply_patch reports the patch text, not a file path; format the .nix files
    # it names so a headless run leaves the tree formatted.
    formatNix = ''
      printf '%s\n' "$(jq -r '.tool_input.command // empty')" \
        | sed -n 's/^\*\*\* \(Update\|Add\) File: //p' \
        | while IFS= read -r file; do
            case "$file" in *.nix) ${lib.getExe pkgs.alejandra} "$file" ;; esac
          done
    '';
  in {
    programs.codex = {
      enable = true;
      package = lib.mkDefault pkgs.llm-agents.codex;
      context = config.agents.md.text;
      enableMcpIntegration = true;
      # Codex rewrites config.toml at runtime; merge instead of a read-only store link.
      mutableSettings = true;

      settings = {
        # Headless runs cannot answer prompts; keep what they can touch small.
        sandbox_mode = "workspace-write";
        sandbox_workspace_write.network_access = false;
        allow_login_shell = false;
        project_doc_max_bytes = 65536;
        web_search = "cached";
        history = {
          persistence = "save-all";
          max_bytes = 268435456;
        };
        # No product telemetry and no analytics exporter.
        analytics.enabled = false;
        feedback.enabled = false;
        otel.exporter = "none";
        # Provider keys stay out of model-spawned shells.
        shell_environment_policy = {
          "inherit" = "core";
          ignore_default_excludes = false;
          filters = {
            "AWS_*" = "exclude";
            "AZURE_*" = "exclude";
            "CODEBERG_*" = "exclude";
            "CURSOR_*" = "exclude";
            "DEEPSEEK_*" = "exclude";
            "GITHUB_*" = "exclude";
            "OPENAI_*" = "exclude";
            "ANTHROPIC_*" = "exclude";
            "SOPS_*" = "exclude";
            "SSH_AUTH_SOCK" = "exclude";
          };
        };
      };

      profiles.headless = {
        approval_policy = "never";
        sandbox_mode = "workspace-write";
        sandbox_workspace_write.network_access = false;
      };

      # Rules decide what may leave the sandbox, so they name the actions an
      # unattended run must never escalate to.
      rules.default = ''
        prefix_rule(pattern = ["git", "push"], decision = "forbidden", justification = "Push is a human decision; an agent run commits locally at most.")
        prefix_rule(pattern = ["sudo"], decision = "forbidden", justification = "No privilege escalation from an agent run.")
        prefix_rule(pattern = ["rm", ["-rf", "-fr", "-r"]], decision = "forbidden", justification = "Delete through git or the reviewed diff.")
        prefix_rule(pattern = ["dd"], decision = "forbidden")
        prefix_rule(pattern = ["mkfs"], decision = "forbidden")
        prefix_rule(pattern = ["chmod", "777"], decision = "forbidden")
      '';

      hooks.PostToolUse = [
        {
          matcher = "apply_patch|Edit|Write";
          hooks = [
            {
              type = "command";
              command = formatNix;
              statusMessage = "Formatting .nix edits";
              timeout = 30;
            }
          ];
        }
      ];
    };

    agents.md.coding-agents = [
      "- `codex`: OpenAI Codex CLI. Headless: `codex exec --profile headless -m <model> -c model_reasoning_effort=\"<low|medium|high|xhigh|max>\" \"<prompt>\"`; the profile never asks and keeps writes inside the workspace with no network."
    ];
  };
in {
  # Features
  features.home.ai.codex = out;

  # Home Manager Modules
  flake.homeModules.default.imports = [config.features.home.ai.codex];
}

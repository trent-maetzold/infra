{config, ...}: let
  out = {
    config,
    lib,
    pkgs,
    ...
  }: let
    home = config.home.homeDirectory;
  in {
    programs.claude-code = {
      enable = true;
      # llm-agents' build is not marked unfree, unlike nixpkgs' claude-code.
      package = lib.mkDefault pkgs.llm-agents.claude-code;
      context = config.agents.md.text;
      enableMcpIntegration = true;
      # Claude Code rewrites settings.json at runtime; merge instead of a read-only store link.
      mutableSettings = true;

      settings = {
        # No "Co-Authored-By: Claude" trailer on commits, no attribution in PR text.
        attribution = false;
        includeCoAuthoredBy = false;

        # Local-only: keep a week of transcripts, never start Remote Control.
        cleanupPeriodDays = 7;
        disableRemoteControl = true;

        # Headless: accept edits and auto-allow sandboxed Bash, but deny the
        # actions an unattended run must not take.
        permissions = {
          defaultMode = "acceptEdits";
          deny = [
            "Read(~/.ssh/**)"
            "Read(~/.aws/**)"
            "Read(~/.gnupg/**)"
            "Read(~/.dsh/.credentials.yaml)"
            "Read(~/.codex/auth.json)"
            "Read(~/.claude/.credentials.json)"
            "Read(./**/.env*)"
            "Read(./**/secrets/**)"
            "Read(./**/*.age)"
            "Read(./**/*.key)"
            "Read(./**/*.pem)"
            "Edit(~/.ssh/**)"
            "Edit(~/.aws/**)"
            "Edit(./**/.env*)"
            "Edit(./**/secrets/**)"
            "Bash(git push)"
            "Bash(git push *)"
            "Bash(sudo *)"
            "Bash(rm -rf *)"
            "Bash(rm -fr *)"
            "Bash(dd *)"
            "Bash(mkfs *)"
            "Bash(chmod 777 *)"
          ];
        };

        sandbox = {
          enabled = true;
          failIfUnavailable = true;
          autoAllowBashIfSandboxed = true;
          network = {
            allowedDomains = [
              "cache.nixos.org"
              "github.com"
              "codeload.github.com"
              "codeberg.org"
              "registry.npmjs.org"
              "pypi.org"
              "files.pythonhosted.org"
            ];
            strictAllowlist = true;
          };
          filesystem = {
            denyRead = [
              "${home}/.ssh"
              "${home}/.aws"
              "${home}/.gnupg"
              "${home}/.dsh/.credentials.yaml"
              "${home}/.codex/auth.json"
              "${home}/.claude/.credentials.json"
            ];
            denyWrite = [
              "${home}/.ssh"
              "${home}/.aws"
            ];
          };
        };

        # No product telemetry, error reports, or feedback uploads; keep
        # provider keys out of the shell environment.
        env = {
          CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC = "1";
          CLAUDE_CODE_DISABLE_FEEDBACK_SURVEY = "1";
          CLAUDE_CODE_SUBPROCESS_ENV_SCRUB = "1";
          DISABLE_AUTOUPDATER = "1";
          DISABLE_FEEDBACK_COMMAND = "1";
        };

        hooks.PostToolUse = [
          {
            matcher = "Edit|Write";
            hooks = [
              {
                type = "command";
                command = ''file=$(jq -r '.tool_input.file_path // empty'); case "$file" in *.nix) ${lib.getExe pkgs.alejandra} "$file" ;; esac'';
              }
            ];
          }
        ];
      };
    };

    agents.md.coding-agents = [
      "- `claude`: Claude Code. Headless: `claude -p \"<prompt>\" --model <model> --effort <low|medium|high|xhigh|max|ultracode>`; settings accept edits, sandbox Bash to the workspace, and allow only the listed network hosts."
    ];
  };
in {
  # Features
  features.home.ai.claude-code = out;

  # Home Manager Modules
  flake.homeModules.default.imports = [config.features.home.ai.claude-code];
}

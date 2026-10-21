{config, ...}: let
  out = {pkgs, ...}: {
    agents.md.tools = [
      "- `agent-browser`: drive a headless browser: `agent-browser open <url>`, then `snapshot`, `click`, `fill`."
      "- `claude`: Claude Code, Anthropic's agent: `claude`."
      "- `codex`: OpenAI Codex CLI: `codex`."
      "- `opencode`: OpenCode, model-agnostic agent: `opencode`."
      "- `pi`: Pi ACP agent: `pi`."
      "- `antigravity`: Antigravity CLI, Google's Go agent: `antigravity`."
      "- `amp`: Sourcegraph Amp: `amp`."
      "- `goose`: Goose, MCP-native local agent: `goose`."
      "- `crush`: Charm Crush: `crush`."
      "- `droid`: Factory Droid: `droid`."
      "- `qwen`: Qwen Code: `qwen`."
      "- `kimi`: Kimi Code: `kimi`."
      "- `cursor-agent`: Cursor CLI: `cursor-agent`."
      "- `copilot`: GitHub Copilot CLI: `copilot`."
      "- `codegraph`: semantic code graph for the repo; `codegraph init` once, auto-syncs. Use `codegraph_explore` over MCP."
      "- `jscpd`: copy/paste detector: `jscpd --threshold 5 .`."
      "- `qmd`: local search over docs and notes: `qmd search <query>`."
      "- `rtk`: prefix noisy commands to compact their output: `rtk git status`, `rtk cargo test`."
    ];

    home.packages = with pkgs;
      [ffmpeg jq ungoogled-chromium]
      ++ (with llm-agents; [
        agent-browser
        bernstein
        but
        codegraph
        cursor-agent
        dsh
        freebuff
        gnhf
        jscpd
        qmd
        rtk
        tuicr
      ]);
  };
in {
  # Features
  features.home.packages.ai = out;

  # Home Manager Modules
  flake.homeModules.default.imports = [config.features.home.packages.ai];
}

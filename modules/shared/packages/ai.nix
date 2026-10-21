{config, ...}: let
  out = {pkgs, ...}: {
    agents.md.tools = [
      "- `agent-browser`: drive a headless browser: `agent-browser open <url>`, then `snapshot`, `click`, `fill`."
      "- `bernstein`: govern agent runs, deterministic scheduling, isolated worktrees, signed audit trail: `bernstein`."
      "- `but`: GitButler CLI, virtual branches and stacked commits: `but`."
      "- `codegraph`: semantic code graph for the repo; `codegraph init` once, auto-syncs. Use `codegraph_explore` over MCP."
      "- `gnhf`: keep coding agents running unattended: `gnhf`."
      "- `jscpd`: copy/paste detector: `jscpd --threshold 5 .`."
      "- `qmd`: local search over docs and notes: `qmd search <query>`."
      "- `rtk`: prefix noisy commands to compact their output: `rtk git status`, `rtk cargo test`."
      "- `tuicr`: review an AI-generated diff like a pull request: `tuicr`."
      "- `ffmpeg`, `jq`, `ungoogled-chromium`: base utilities; `agent-browser` drives the Chromium."
    ];

    home.packages = with pkgs;
      [ffmpeg jq ungoogled-chromium]
      ++ (with llm-agents; [
        agent-browser
        bernstein
        but
        codegraph
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

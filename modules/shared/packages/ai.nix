{config, ...}: let
  out = {pkgs, ...}: {
    agents.md.tools = [
      "- `agent-browser`: drive a headless browser: `agent-browser open <url>`, then `snapshot`, `click`, `fill`."
      "- `gitnexus`: code graph of the repo: `gitnexus analyze`, then `query`, `context`, `impact`."
      "- `openspec`: spec-driven changes: `openspec list`, `openspec show <change>`."
      "- `qmd`: local search over docs and notes: `qmd search <query>`."
      "- `rtk`: prefix noisy commands to compact their output: `rtk git status`, `rtk cargo test`."
    ];

    home.packages = with pkgs;
      [ffmpeg jq ungoogled-chromium]
      ++ (with llm-agents; [
        agent-browser
        bernstein
        but
        cursor-agent
        dsh
        freebuff
        gitnexus
        gnhf
        openspec
        openspecui
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

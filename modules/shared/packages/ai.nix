{
  flake.home.packages.ai = {pkgs, ...}: {
    home.packages = with pkgs;
      [ffmpeg jq ungoogled-chromium]
      ++ (with llm-agents; [
        agent-browser
        bernstein
        but
        dsh
        freebuff
        gitnexus
        gnhf
        openspec
        openspecui
        qmd
      ]);
  };
}

let
  out = {pkgs, ...}: {
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
in {
  # Features
  features.home.packages.ai = out;
}

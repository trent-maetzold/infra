{config, ...}: let
  out = {pkgs, ...}: {
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
      ]);
  };
in {
  # Features
  features.home.packages.ai = out;

  # Home Manager Modules
  flake.homeModules.default.imports = [config.features.home.packages.ai];
}

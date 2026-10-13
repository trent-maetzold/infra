{config, ...}: {
  flake.home.ai.agents = {pkgs, ...}: {
    home = {
      file.".agents" = {
        source = ./config;
        recursive = true;
      };
      packages = with pkgs;
        (with llm-agents; [
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
        ])
        ++ [
          ffmpeg
          jq
          tmux
          ungoogled-chromium
        ];
    };
  };
  flake.homeModules.default.imports = [config.flake.home.ai.agents];
}

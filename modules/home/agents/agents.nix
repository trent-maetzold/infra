{config, ...}: {
  flake.modules.homeManager.agents = {pkgs, ...}: {
    home = {
      file.".agents" = {
        source = ./config;
        recursive = true;
      };
      packages = with pkgs;
        (with llm-agents; [
          agent-browser
          but
          gitnexus
          gnhf
        ])
        ++ [
          ffmpeg
          jq
          tmux
          ungoogled-chromium
        ];
    };
  };
  flake.homeModules.default.imports = [config.flake.modules.homeManager.agents];
}

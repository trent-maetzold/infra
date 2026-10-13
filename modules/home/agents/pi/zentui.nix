{config, ...}: {
  flake.modules.homeManager.agents-pi-zentui = {...}: {
    config = {
      programs.pi-coding-agent.settings.packages = ["npm:pi-zentui"];

      home.file.".pi/agent/zentui.json".text = builtins.toJSON {
        components = {
          editor = {
            borderColorMode = "adaptive";
            style = "minimalist";
            styles = {
              opencode.metadataFormat = "$model  $provider(  $thinking)";
              "opencode-copy-friendly".metadataFormat = "$model  $provider(  $thinking)";
              minimalist = {
                pathDisplay = "project";
                contextFormat = "percent-total";
                contextGauge = true;
              };
            };
          };
          userMessages.style = "compact";
          footer.styles.starship = {
            responsive = false;
            compactFormat = "$cwd$wrap(in $session_name)$wrap(on $git_branch) $git_status$wrap$context$wrap_sep$tokens";
            contextStyle = "gauge";
            segments = {
              context = false;
              cost = false;
              cwd = false;
              gitBranch = false;
              gitStatus = false;
            };
            extensionStatuses = {
              defaultPlacement = "left";
              colorModes = {
                caveman = "zentui";
                mcp = "zentui";
                ponytail = "zentui";
              };
              placements = {
                caveman = "left";
                mcp = "left";
                ponytail = "left";
              };
            };
          };
          workingLine.enabled = true;
        };
        icons.mode = "nerd";
      };
    };
  };
  flake.homeModules.default.imports = [config.flake.modules.homeManager.agents-pi-zentui];
}

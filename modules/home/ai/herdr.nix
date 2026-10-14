{config, ...}: let
  out = {pkgs, ...}: {
    programs.herdr = {
      enable = true;
      package = pkgs.llm-agents.herdr;
      settings = {
        onboarding = false;
        ui = {
          sidebar_width = 32;
          agent_panel_sort = "priority";
          status_indicators = "symbols";
          show_agent_labels_on_pane_borders = true;
          toast.delivery = "herdr";
          sound.enabled = true;
        };
      };
    };
  };
in {
  # Features
  features.home.ai.herdr = out;

  # Home Manager Modules
  flake.homeModules.default.imports = [config.features.home.ai.herdr];
}

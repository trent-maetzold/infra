{config, ...}: {
  flake.modules.homeManager.agents-herdr = {pkgs, ...}: {
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
  flake.homeModules.default.imports = [config.flake.modules.homeManager.agents-herdr];
}

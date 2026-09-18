{
  config,
  lib,
  pkgs,
  ...
}: {
  config = lib.mkMerge [
    {programs.herdr.enable = lib.mkDefault true;}
    (lib.mkIf config.programs.herdr.enable {
      programs.herdr = {
        package = pkgs.llm-agents.herdr;
        settings = {
          onboarding = false;
          ui = {
            sidebar_width = 32;
            agent_panel_sort = "priority";
            status_indicators = "symbols";
            show_agent_labels_on_pane_borders = true;
            toast.delivery = "system";
            sound.enabled = true;
          };
        };
      };
    })
  ];
}

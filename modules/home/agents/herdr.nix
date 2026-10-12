{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.programs.herdr;
in {
  config = lib.mkMerge [
    {programs.herdr.enable = lib.mkDefault true;}
    (lib.mkIf cfg.enable {
      programs.herdr = {
        package = lib.mkDefault pkgs.llm-agents.herdr;
        settings = {
          onboarding = lib.mkDefault false;
          # keys.command = lib.mkDefault [
          #   {
          #     key = "prefix+e";
          #     type = "plugin_action";
          #     command = "chmarax.herdr-nvim.toggle";
          #     description = "nvim sidebar";
          #   }
          #   {
          #     key = "prefix+o";
          #     type = "plugin_action";
          #     command = "chmarax.herdr-nvim.pick-file";
          #     description = "open file from agent output";
          #   }
          # ];
          ui = {
            sidebar_width = lib.mkDefault 32;
            agent_panel_sort = lib.mkDefault "priority";
            status_indicators = lib.mkDefault "symbols";
            show_agent_labels_on_pane_borders = lib.mkDefault true;
            toast.delivery = lib.mkDefault "herdr";
            sound.enabled = lib.mkDefault true;
          };
        };
      };
    })
  ];
}

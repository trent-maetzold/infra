{
  config,
  lib,
  pkgs,
  ...
}: {
  config = lib.mkMerge [
    {programs.pi-coding-agent.enable = lib.mkDefault true;}
    (lib.mkIf config.programs.pi-coding-agent.enable {
      programs.pi-coding-agent = {
        settings = {
          packages = [
            "npm:billion-context-pi"
            "npm:pi-caveman"
            "npm:pi-committer"
            "npm:pi-mcp-adapter"
            "npm:pi-memory"
            "npm:pi-reasonix"
            "npm:pi-simplify"
            "npm:pi-subagents"
            "npm:pi-web-access"
            "npm:pi-zentui"
            "npm:@dietrichgebert/ponytail"
          ];
          theme = "dark";
          defaultProvider = "opencode-go";
          defaultModel = "deepseek-v4-flash";
          defaultThinkingLevel = "max";
        };
        extraPackages = with pkgs; [
          nodejs
          bun
        ];
      };
      home.file.".pi/agent/zentui.json".source = lib.mkDefault ../../config/pi/packages/zentui.json;
    })
  ];
}

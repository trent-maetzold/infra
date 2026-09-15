{
  config,
  lib,
  pkgs,
  ...
}: {
  config = lib.mkMerge [
    {programs.pi-coding-agent.enable = lib.mkDefault true;}
    (lib.mkIf config.programs.pi-coding-agent.enable {
      programs.pi-coding-agent = lib.mkDefault {
        extraPackages = with pkgs; [
          nodejs
          bun
        ];
        settings = {
          packages = [
            "npm:pi-zentui"
            "npm:pi-blackhole"
            "npm:pi-mcp-adapter"
            "npm:pi-simplify"
            "npm:pi-caveman"
            "npm:@dietrichgebert/ponytail"
          ];
          theme = "dark";
          defaultProvider = "opencode-go";
          defaultModel = "deepseek-v4-flash";
          defaultThinkingLevel = "max";
        };
      };
      home.file.".pi/agent/zentui.json".source = lib.mkDefault ../../config/pi/packages/zentui.json;
    })
  ];
}

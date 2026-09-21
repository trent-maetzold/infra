{
  config,
  lib,
  pkgs,
  ...
}: {
  options.programs.agents.enable = lib.mkEnableOption "agents";

  imports = [
    ./herdr.nix
    ./mcp.nix
    ./pi.nix
  ];

  config = lib.mkMerge [
    {programs.agents.enable = lib.mkDefault true;}
    (lib.mkIf config.programs.agents.enable {
      home = {
        packages = with pkgs.llm-agents; [
          bernstein
          gnhf
          openspec
          openspecui
          qmd
        ];
        file = {
          ".agents" = {
            source = lib.mkDefault ../../config/agents;
            recursive = lib.mkDefault true;
          };
        };
        shellAliases.mini = lib.mkDefault "uvx --from mini-swe-agent mini";
      };
    })
  ];
}

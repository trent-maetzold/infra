{
  config,
  lib,
  pkgs,
  ...
}: {
  options.programs.agents.enable = lib.mkEnableOption "agents";

  imports = [
    ./dsh.nix
    ./mcp.nix
    ./pi.nix
  ];

  config = lib.mkMerge [
    {programs.agents.enable = lib.mkDefault true;}
    (lib.mkIf config.programs.agents.enable {
      home = {
        packages = lib.mkDefault (with pkgs.llm-agents; [
          bernstein
          freebuff
          gnhf
          herdr
          openspec
          openspecui
        ]);
        file = {
          ".agents" = {
            source = lib.mkDefault ../../config/agents;
            recursive = true;
          };
        };
        shellAliases.mini = lib.mkDefault "uvx --from mini-swe-agent mini";
      };
    })
  ];
}

{config, ...}: {
  flake.homeModules.agents-mcp = {
    config,
    lib,
    ...
  }: let
    cfg = config.programs.mcp;
  in {
    config = lib.mkMerge [
      {programs.mcp.enable = lib.mkDefault true;}
      (lib.mkIf cfg.enable {
        programs.mcp.servers = {
          context7.url = lib.mkDefault "https://mcp.context7.com/mcp";
          deepwiki.url = lib.mkDefault "https://mcp.deepwiki.com/mcp";
        };
      })
    ];
  };
  flake.homeModules.default.imports = [config.flake.homeModules.agents-mcp];
}

{
  config,
  lib,
  ...
}: {
  config = lib.mkMerge [
    {programs.mcp.enable = lib.mkDefault true;}
    (lib.mkIf config.programs.mcp.enable {
      programs.mcp = {
        servers = lib.mkDefault {
          context7 = {
            url = "https://mcp.context7.com/mcp";
          };
          deepwiki = {
            url = "https://mcp.deepwiki.com/mcp";
          };
          parallel-search = {
            url = "https://search.parallel.ai/mcp";
            directTools = true;
          };
        };
      };
    })
  ];
}

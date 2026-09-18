{
  config,
  lib,
  ...
}: {
  config = lib.mkMerge [
    {programs.mcp.enable = lib.mkDefault true;}
    (lib.mkIf config.programs.mcp.enable {
      programs.mcp = {
        # mkDefault per leaf, never on the attrset (see home/modules/neovim/default.nix).
        servers = {
          context7.url = lib.mkDefault "https://mcp.context7.com/mcp";
          deepwiki.url = lib.mkDefault "https://mcp.deepwiki.com/mcp";
          parallel-search = {
            url = lib.mkDefault "https://search.parallel.ai/mcp";
            directTools = lib.mkDefault true;
          };
        };
      };
    })
  ];
}

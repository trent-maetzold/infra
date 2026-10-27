# maki, a Rust coding agent with Lua plugins, from its own flake.
{config, ...}: let
  modules.homeManager = {
    config,
    lib,
    pkgs,
    ...
  }: let
    servers = lib.filterAttrs (_: server: server.url != null) config.programs.mcp.servers;

    mcp = (pkgs.formats.toml {}).generate "maki-mcp.toml" {
      mcp = lib.mapAttrs (_: server: {inherit (server) url;}) servers;
    };
  in {
    home.packages = [pkgs.maki];

    # maki's /mcp picker writes mcp.toml, so activation installs a mutable copy.
    home.activation.makiMcp = lib.hm.dag.entryAfter ["writeBoundary"] ''
      run install -Dm 644 ${mcp} "${config.xdg.configHome}/maki/mcp.toml"
    '';

    agents.md.coding-agents = [
      "- `maki`: Rust agent with Lua plugins and MCP tool search. Headless: `maki -p --model <provider/model> \"<prompt>\"`."
    ];
  };
in {
  # Flake Modules
  flake.modules.homeManager.maki = modules.homeManager;

  # Home Configuration Modules
  flake.homeModules.default.imports = [config.flake.modules.homeManager.maki];
}

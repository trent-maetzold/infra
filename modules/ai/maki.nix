# maki, a Rust coding agent with Lua plugins, from its own flake.
{
  config,
  jail-nix,
  ...
}: let
  modules.homeManager = {
    config,
    lib,
    pkgs,
    ...
  }: let
    mcp = (pkgs.formats.toml {}).generate "maki-mcp.toml" {mcp.gateway = {inherit (config.programs.mcp.servers.gateway) url;};};
    makeJail = import ./_lib/make-jail.nix {inherit config jail-nix pkgs;};
  in {
    home.packages = [
      (makeJail "maki" pkgs.maki {
        state = with config.xdg; ["${configHome}/maki" "${dataHome}/maki" "${stateHome}/maki" "${cacheHome}/maki"];
      })
    ];

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

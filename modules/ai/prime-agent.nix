# prime-agent, Prime Intellect's RLM agent (a pi fork), with the shared MCP servers.
{config, ...}: let
  modules.homeManager = {
    config,
    lib,
    pkgs,
    ...
  }: let
    mcp = config.xdg.configFile."mcp/mcp.json".source;
    settings = "${config.home.homeDirectory}/.prime/agent/settings.json";
  in {
    home.packages = [pkgs.llm-agents.prime-agent];

    # prime-agent rewrites settings.json; merge so /mcp edits survive, and keep the servers.
    home.activation.primeMcp = lib.hm.dag.entryAfter ["writeBoundary"] ''
      merged=$(${pkgs.jq}/bin/jq -s '.[0] * .[1]' "${settings}" ${mcp} 2>/dev/null || cat ${mcp})
      run rm -f "${settings}"
      run install -Dm 644 /dev/stdin "${settings}" <<< "$merged"
    '';

    agents.md.coding-agents = [
      "- `prime-agent`: Prime Intellect's recursive-language-model agent (a pi fork). Headless: `prime-agent -p \"<prompt>\" --model <model> --thinking <off|minimal|low|medium|high|xhigh|max>`."
    ];
  };
in {
  # Flake Modules
  flake.modules.homeManager.prime-agent = modules.homeManager;

  # Home Configuration Modules
  flake.homeModules.default.imports = [config.flake.modules.homeManager.prime-agent];
}

# prime-agent, Prime Intellect's RLM agent (a pi fork), with the MCP gateway.
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
    mergeJson = import ./_lib/make-merged-json.nix;
    mcp = pkgs.writeText "mcp.json" (builtins.toJSON {
      mcpServers.gateway = {
        type = "http";
        inherit (config.programs.mcp.servers.gateway) url;
      };
    });
    settings = "${config.home.homeDirectory}/.prime/agent/settings.json";
    makeJail = import ./_lib/make-jail.nix {inherit config jail-nix pkgs;};
  in {
    # prime-agent has no XDG or home override, so its state stays in ~/.prime.
    home.packages = [(makeJail "prime-agent" pkgs.llm-agents.prime-agent {state = ["${config.home.homeDirectory}/.prime"];})];

    # prime-agent rewrites settings.json; merge so /mcp edits survive, and keep the servers.
    home.activation.primeMcp = lib.hm.dag.entryAfter ["writeBoundary"] (mergeJson pkgs settings mcp);

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

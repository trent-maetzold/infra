# Prime Agent with Magpie's models; credentials stay in its private auth store or environment.
{config, ...}: let
  magpie = import ./_lib/magpie.nix;
  models = magpie.makeModels config.flake.lib.makePrimeModel;

  modules.homeManager = {pkgs, ...}: {
    home.packages = [pkgs.llm-agents.prime-agent];
  };
in {
  # Flake Modules
  flake.modules.homeManager.prime-agent = modules.homeManager;

  # Home Configuration Modules
  flake.homeModules.default.imports = [
    config.flake.modules.homeManager.prime-agent
    {
      home.file.".prime/agent/models.json".text = builtins.toJSON {
        providers.magpie = {
          inherit (magpie) name baseUrl;
          inherit models;
          api = "openai-completions";
          apiKey = "!printenv ${magpie.apiKeyEnv}";
        };
      };
    }
  ];
}

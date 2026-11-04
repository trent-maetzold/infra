# Autolith with Magpie's models; its auth command manages the private API-key store.
{config, ...}: let
  magpie = import ./_lib/magpie.nix;
  models = magpie.makeModelText config.flake.lib.makeAutolithModel;

  modules.homeManager = {pkgs, ...}: {
    home.packages = [pkgs.autolith];
  };
in {
  # Flake Modules
  flake.modules.homeManager.autolith = modules.homeManager;

  # Home Configuration Modules
  flake.homeModules.default.imports = [
    config.flake.modules.homeManager.autolith
    {
      xdg.configFile."autolith/init.lisp".text = ''
        (register-openai-compatible-provider
         :name "${magpie.name}"
         :description "Magpie gateway"
         :endpoint "${magpie.baseUrl}/chat/completions"
         :models '(${models}))
      '';
    }
  ];
}

# The plugin system: one option for plugin directories, rendered into the
# extraPlugins links and the enabled list Hermes reads.
{config, ...}: let
  out = {
    config,
    lib,
    pkgs,
    ...
  }: let
    plugins = config.my.hermes.plugins;

    # A plugin is a directory with plugin.yaml at its root, and `extraPlugins`
    # wants that directory, so pack the subtree.
    pack = name: plugin: pkgs.runCommand name {} "cp -r ${plugin.src} $out";
  in {
    options.my.hermes.plugins = lib.mkOption {
      type = lib.types.attrsOf (lib.types.submodule {
        options = {
          src = lib.mkOption {
            type = lib.types.path;
            description = "The plugin's directory.";
          };

          enable = lib.mkOption {
            type = lib.types.bool;
            default = true;
            description = "Whether Hermes loads it; one that is only a provider needs linking, not enabling.";
          };
        };
      });
      default = {};
      description = "Plugins by the name in their plugin.yaml, linked as nix-managed-<name>.";
    };

    config.services.hermes-agent = {
      extraPlugins = lib.mapAttrsToList pack plugins;

      settings.plugins.enabled = lib.attrNames (lib.filterAttrs (_: plugin: plugin.enable) plugins);
    };
  };
in {
  my.services.hermes.modules = [out];
}

# OH-MY-HERMES: its routes, plans and evidence skills.
{oh-my-hermes, ...}: let
  out = {pkgs, ...}: {
    services.hermes-agent = {
      extraPlugins = [(pkgs.runCommand "omh" {} "cp -r ${oh-my-hermes}/src/plugin_bundle/omh $out")];
    };
  };
in {
  my.services.hermes.modules = [out];
}

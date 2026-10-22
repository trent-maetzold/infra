# OH-MY-HERMES: its routes, plans and evidence skills.
{oh-my-hermes, ...}: let
  out = {my.hermes.plugins.omh.src = "${oh-my-hermes}/src/plugin_bundle/omh";};
in {
  my.services.hermes.modules = [out];
}

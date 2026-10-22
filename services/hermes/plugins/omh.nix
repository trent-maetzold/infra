# OH-MY-HERMES: its routes, plans and evidence skills.
{oh-my-hermes, ...}: {
  my.services.hermes.modules = [
    {my.hermes.plugins.omh.src = "${oh-my-hermes}/src/plugin_bundle/omh";}
  ];
}

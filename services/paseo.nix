# Paseo on yggdrasil, reached through its hosted relay.
{
  my.services.paseo = {
    host = "yggdrasil";

    modules = [
      ({paseo, ...}: {
        imports = [paseo.nixosModules.default];
        services.paseo.enable = true;
      })
    ];
  };
}

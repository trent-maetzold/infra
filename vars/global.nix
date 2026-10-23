# Shared by every host and user: the values features read from `config.vars`.
{config, ...}: {
  vars.global = {
    vars = {
      domain = "trkm.io";
      acmeEmail = "tkm89@proton.me";

      tailnet = {
        loginServer = "https://hs.trkm.io";
        domain = "ts.trkm.io";
        subnet = "100.64.0.0/10";
      };
    };
  };
}

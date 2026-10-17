# Shared by every host and user: the flake's stateVersion and the values
# features read from `config.vars`.
{config, ...}: {
  vars.global = {
    imports = [(config.flake.lib.makeStateVersion "26.11")];

    vars = {
      domain = "trkm.io";
      acmeEmail = "tkm89@proton.me";
      # yggdrasil's traefik, behind heimdall's caddy.
      ingress = "100.64.0.3";
      # hermes-ssh's server
      hermes = "yggdrasil.ts.trkm.io";

      tailnet = {
        loginServer = "https://hs.trkm.io";
        domain = "ts.trkm.io";
        subnet = "100.64.0.0/10";
      };
    };
  };
}

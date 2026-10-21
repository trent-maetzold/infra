# Shared by every host and user: the values features read from `config.vars`.
{config, ...}: {
  vars.global = {
    vars = {
      domain = "trkm.io";
      acmeEmail = "tkm89@proton.me";
      # yggdrasil's traefik, behind heimdall's caddy.
      ingress = "100.64.0.3";

      tailnet = {
        loginServer = "https://hs.trkm.io";
        domain = "ts.trkm.io";
        subnet = "100.64.0.0/10";
      };

      # Runner MicroVMs beside the forge; see services/forgejo.nix.
      forgejo.runners = 3;
    };
  };
}

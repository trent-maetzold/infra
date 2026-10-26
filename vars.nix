# Shared by every host and user: the values features read from `config.vars`.
let
  globals = {
    vars = {
      domain = "trkm.io";
      acmeEmail = "tkm89@proton.me";
      timeZone = "America/Chicago";
      flake = "/home/tm/code/asgard";

      tailnet = {
        loginServer = "https://hs.trkm.io";
        domain = "ts.trkm.io";
        subnet = "100.64.0.0/10";
      };
    };
  };
in {
  flake.homeModules.globals = globals;
  flake.nixosModules.globals = globals;
}

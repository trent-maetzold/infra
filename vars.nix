# Shared by every host and user: the values features take as module args,
# merged into the flake's inputs.
{
  domain = "trkm.io";
  acmeEmail = "tkm89@proton.me";
  timeZone = "America/Chicago";
  flakePath = "/home/tm/code/asgard";
  bitwardenEmail = "trent@maetzold.co";
  ageMasterPubkey = "age1gfu7xqt5tdqmg9l6472cgumrkjgg5xk67d9wt04ug0w8zwn9edtsnfclh4";

  tailnet = {
    loginServer = "https://hs.trkm.io";
    domain = "ts.trkm.io";
    subnet = "100.64.0.0/10";
  };
}

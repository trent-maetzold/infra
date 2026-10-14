let
  out = {
    services.tailscale = {
      enable = true;
      authKeyFile = "/run/keys/ts-authkey";
      extraUpFlags = ["--login-server=https://hs.trkm.io"];
      extraSetFlags = ["--netfilter-mode=off"];
    };
  };
in {
  # Features
  features.nixos.network.tailscale-headscale = out;
}

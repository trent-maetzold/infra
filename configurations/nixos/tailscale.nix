{
  flake.modules.nixos.tailscale-headscale = {
    services.tailscale = {
      enable = true;
      authKeyFile = "/run/keys/ts-authkey";
      extraUpFlags = ["--login-server=https://hs.trkm.io"];
      extraSetFlags = ["--netfilter-mode=off"];
    };
  };
}

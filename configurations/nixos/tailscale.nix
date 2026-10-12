{
  flake.nixosModules.tailscale-headscale = {
    config,
    lib,
    ...
  }: {
    config = lib.mkIf config.services.tailscale.enable {
      services.tailscale = {
        authKeyFile = "/run/keys/ts-authkey";
        extraUpFlags = ["--login-server=https://hs.trkm.io"];
        extraSetFlags = ["--netfilter-mode=off"];
      };
    };
  };
}

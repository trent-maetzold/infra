{config, ...}: let
  out = {config, ...}: {
    networking.firewall.trustedInterfaces = ["tailscale0"];

    services.tailscale = {
      enable = true;
      authKeyFile = "/run/keys/ts-authkey";
      extraUpFlags = ["--login-server=${config.vars.tailnet.loginServer}"];
      extraSetFlags = ["--netfilter-mode=off"];
    };
  };
in {
  # Features
  features.nixos.network.tailscale = out;

  # NixOS Modules
  flake.nixosModules.tailnet.imports = [config.features.nixos.network.tailscale];
}

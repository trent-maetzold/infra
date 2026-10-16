{config, ...}: let
  out = {config, ...}: {
    services.tailscale = {
      enable = true;
      authKeyFile = "/run/keys/ts-authkey";
      extraUpFlags = ["--login-server=${config.vars.tailnet.loginServer}"];
      extraSetFlags = ["--netfilter-mode=off"];
    };
  };
in {
  # Modules
  my.modules.network.tailscale.nixos = out;

  # NixOS Modules
  flake.nixosModules.tailnet.imports = [config.my.modules.network.tailscale.nixos];
}

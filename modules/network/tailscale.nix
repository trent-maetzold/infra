# Tailscale, joined to this flake's headscale; the tailnet interface is
# trusted. `tailscale-auth` also logs in with the `ts-authkey` file.
{config, ...}: let
  modules.nixos = {config, ...}: {
    networking.firewall.trustedInterfaces = ["tailscale0"];

    services.tailscale = {
      enable = true;
      extraUpFlags = ["--login-server=${config.vars.tailnet.loginServer}"];
      extraSetFlags = ["--netfilter-mode=off"];
    };
  };

  modules.nixos-auth = {ts-authkey, ...}: {
    imports = [modules.nixos];

    services.tailscale.authKeyFile = ts-authkey;
  };
in {
  # Flake Modules
  flake.modules.nixos.tailscale = modules.nixos;
  flake.modules.nixos.tailscale-auth = modules.nixos-auth;

  # NixOS Configuration Modules
  flake.nixosModules = {
    heimdall.imports = [config.flake.modules.nixos.tailscale-auth];
    yggdrasil.imports = [config.flake.modules.nixos.tailscale-auth];
  };
}

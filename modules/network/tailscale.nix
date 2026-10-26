# Tailscale, joined to this flake's headscale; the tailnet interface is
# trusted.
{config, ...}: let
  modules.nixos = {config, ...}: {
    networking.firewall.trustedInterfaces = ["tailscale0"];

    services.tailscale = {
      enable = true;
      authKeyFile = "/run/keys/ts-authkey";
      extraUpFlags = ["--login-server=${config.vars.tailnet.loginServer}"];
      extraSetFlags = ["--netfilter-mode=off"];
    };
  };
in {
  # Flake Modules
  flake.modules.nixos.tailscale = modules.nixos;

  # NixOS Configuration Modules
  flake.nixosModules = {
    heimdall.imports = [config.flake.modules.nixos.tailscale];
    yggdrasil.imports = [config.flake.modules.nixos.tailscale];
  };
}

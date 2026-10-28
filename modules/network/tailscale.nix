# Tailscale, joined to this flake's headscale; the tailnet interface is
# trusted.
{config, ...}: let
  modules.nixos = {
    config,
    secrets ? {},
    ...
  }: {
    networking.firewall.trustedInterfaces = ["tailscale0"];

    services.tailscale = {
      enable = true;
      # Auth only when the consumer's secrets specialArg names the key; unset, tailscale just stays unauthenticated.
      authKeyFile = secrets.ts-authkey or null;
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

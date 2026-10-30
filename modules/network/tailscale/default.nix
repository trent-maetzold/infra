# Tailscale, joined to this flake's headscale; the tailnet interface is
# trusted. `tailscale-auth` also logs in with the `ts-authkey` file.
{config, ...}: let
  modules.nixos = {tailnet, ...}: {
    networking.firewall.trustedInterfaces = ["tailscale0"];

    services.tailscale = {
      enable = true;
      extraUpFlags = ["--login-server=${tailnet.loginServer}"];
      extraSetFlags = ["--netfilter-mode=off"];
    };
  };

  modules.nixos-auth = {ts-authkey, ...}: {
    imports = [modules.nixos];

    services.tailscale.authKeyFile = ts-authkey;
  };

  # This flake's tailnet key.
  authkey = {config, ...}: {
    sops.secrets.ts-authkey.sopsFile = ./secrets.yaml;
    _module.args.ts-authkey = config.sops.secrets.ts-authkey.path;
  };
in {
  # Flake Modules
  flake.modules.nixos.tailscale = modules.nixos;
  flake.modules.nixos.tailscale-auth = modules.nixos-auth;

  # NixOS Configuration Modules
  flake.nixosModules = {
    frigg.imports = [config.flake.modules.nixos.tailscale-auth authkey];
    heimdall.imports = [config.flake.modules.nixos.tailscale-auth authkey];
    thor.imports = [config.flake.modules.nixos.tailscale-auth authkey];
    yggdrasil.imports = [config.flake.modules.nixos.tailscale-auth authkey];
  };
}

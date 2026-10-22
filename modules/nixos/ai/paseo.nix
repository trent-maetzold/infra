# Paseo daemon on loopback (`my.endpoints.paseo`), reached remotely through its
# relay. Every option the upstream module offers, spelled out at its default,
# so what can be set is visible here instead of in the flake.
{paseo, ...}: let
  endpoint = {
    host = "127.0.0.1";
    port = 6767;
  };

  nixos = _: {
    imports = [paseo.nixosModules.default];

    services.paseo = {
      enable = true;
      listenAddress = endpoint.host;
      inherit (endpoint) port;

      user = "paseo";
      group = "paseo";
      dataDir = "/var/lib/paseo";
      openFirewall = false;
      hostnames = [];

      relay = {
        enable = true;
        mode = "hosted";
        host = "";
        port = 443;
        useTls = true;
        publicUseTls = null;
      };

      inheritUserEnvironment = false;
      environment = {};
      # `$PASEO_HOME/config.json`
      settings = {};
    };
  };
in {
  # Features
  features.nixos.ai.paseo = nixos;

  my.endpoints.paseo = endpoint;
}

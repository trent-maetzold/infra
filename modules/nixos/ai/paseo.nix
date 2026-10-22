# Paseo daemon on loopback (`my.endpoints.paseo`), reached remotely through its
# relay. Every option the upstream module offers, spelled out at its default,
# so what can be set is visible here instead of in the flake.
{paseo, ...}: let
  # Reusable: the daemon and its settings, for any host.
  nixosOut = _: {
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

  # Concrete: this flake's paseo, imported as is by the host that runs it.
  hosts.paseo = {
    imports = [nixosOut];
  };

  endpoint = {
    host = "127.0.0.1";
    port = 6767;
  };
in {
  # Downstream: `asgard.modules.nixos.paseo`.
  flake.modules.nixos.paseo = nixosOut;

  # Downstream: `asgard.nixosModules.paseo`.
  flake.nixosModules.paseo.imports = [hosts.paseo];

  my.endpoints.paseo = endpoint;
}

{
  config,
  lib,
  hermes-agent,
  ...
}: {
  imports = [
    hermes-agent.nixosModules.default
  ];

  config = lib.mkIf config.services.hermes-agent.enable {
    # Hermes runs as a native systemd service here — on a plain host, a
    # microvm, or inside a NixOS container (containers.*). The upstream
    # OCI container mode (docker/podman) is not used; the upstream module's
    # own assertion already forbids combining it with an extra backend.
    assertions = [
      {
        assertion = !config.services.hermes-agent.container.enable;
        message = ''
          asgard: hermes-agent container mode (services.hermes-agent.container.enable = true)
          is not supported. Use the native systemd service — on a host, a microvm, or
          inside a NixOS container. The container adds a mutable apt/pip layer we don't
          want; store-path hermes is fully self-modifying via its writable HERMES_HOME.
        '';
      }
    ];

    services.hermes-agent.addToSystemPackages = lib.mkDefault true;
  };
}

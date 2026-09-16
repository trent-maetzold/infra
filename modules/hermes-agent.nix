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
    assertions = [
      {
        assertion = !config.services.hermes-agent.container.enable;
        message = ''
          asgard: hermes-agent container mode (services.hermes-agent.container.enable = true)
          is not supported. Asgard runs hermes as a native systemd service — on a host, a
          microvm, or inside a NixOS container. Use those instead of Docker/Podman mode.
        '';
      }
    ];

    services.hermes-agent.addToSystemPackages = lib.mkDefault true;
  };
}

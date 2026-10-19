# Honcho on yggdrasil, reached by hermes on the same host.
{config, ...}: {
  my.services.honcho = {
    host = "yggdrasil";

    modules = [
      config.features.nixos.ai.honcho
      # Volumes, not the image store.
      {persist.dirs."/var/lib/containers/storage/volumes".snapshots = true;}
    ];

    routes.honcho = config.flake.lib.makePrivateRoute config.my.endpoints.honcho;
  };
}

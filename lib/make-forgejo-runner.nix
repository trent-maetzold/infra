# A Forgejo Actions runner, as a NixOS module: jobs labelled `native` run on the
# host with Nix. `tokenFile` holds the registration token — or a `TOKEN=…` env
# file, which forgejo-runner still reads. The instance is named after the host
# unless `name` says otherwise.
{
  flake.lib.makeForgejoRunner = {
    url,
    tokenFile,
    name ? null,
    labels ? ["native:host"],
    packages ? [],
  }: {
    config,
    pkgs,
    ...
  }: let
    instance =
      if name == null
      then config.networking.hostName
      else name;
  in {
    services.gitea-actions-runner = {
      package = pkgs.forgejo-runner;

      instances.${instance} = {
        enable = true;
        name = instance;
        inherit labels tokenFile url;

        hostPackages = with pkgs;
          [bash coreutils curl gitMinimal nix nodejs]
          ++ packages;
      };
    };
  };
}

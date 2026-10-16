# Codeberg Actions runner; jobs labelled `native` run on the host with Nix.
# Expects /var/lib/secrets/forgejo-runner-token holding `TOKEN=<registration token>`.
{
  my.services.forgejo-runner = {
    host = "yggdrasil";

    modules = [
      ({config, pkgs, ...}: {
        services.gitea-actions-runner = {
          package = pkgs.forgejo-runner;

          instances.codeberg = {
            enable = true;
            name = config.networking.hostName;
            url = "https://codeberg.org";
            tokenFile = "/var/lib/secrets/forgejo-runner-token";
            labels = ["native:host"];
            hostPackages = with pkgs; [bash coreutils curl gitMinimal nix nodejs];
          };
        };
      })
    ];
  };
}

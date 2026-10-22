# Codeberg's Actions runner on yggdrasil: `native` jobs run with Nix. Expects
# /var/lib/secrets/forgejo-runner-token holding `TOKEN=<registration token>`.
{config, ...}: {
  my.services.forgejo-runner = {
    host = "yggdrasil";

    modules = [
      (config.flake.lib.makeForgejoRunner {
        url = "https://codeberg.org";
        tokenFile = "/var/lib/secrets/forgejo-runner-token";
      })
    ];
  };
}

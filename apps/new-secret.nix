{config, ...}: {
  perSystem = {pkgs, ...}: {
    packages.new-secret = config.flake.lib.makeCli {
      inherit pkgs;
      name = "new-secret";
      script = builtins.replaceStrings ["@rage@"] ["${pkgs.rage}/bin/rage"] (builtins.readFile ./new-secret.py);
    };
  };
}

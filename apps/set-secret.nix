{
  perSystem = {pkgs, ...}: {
    packages.set-secret = pkgs.writeShellApplication {
      name = "set-secret";
      runtimeInputs = [pkgs.forgejo-cli pkgs.git pkgs.rage];
      text = builtins.readFile ./set-secret.sh;
    };
  };
}

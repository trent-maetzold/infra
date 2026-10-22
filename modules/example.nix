_: let
  # `homeOut`/`nixosOut` are reusable: the attrs and settings every instance
  # gets. Exported as `flake.modules.<class>.<name>` and imported by the
  # concrete attrs below.
  homeOut = {};
  nixosOut = {};

  # `users` and `hosts` are concrete: only the data that differs per instance
  # lives here. `flake.homeModules.<user>` / `flake.nixosModules.<host>` are
  # what `makeUser` and `nixosConfigurations` import, so adding a host here is
  # what makes a service run on it.
  users = {
    example-user.imports = [homeOut];
    example-user-work = {
      imports = [homeOut];
      programs.git.settings.user.email = "example.user@work.com";
    };
  };
  hosts.example-host = {
    imports = [nixosOut];
    services.example.hostnames = ["example.example.net"];
  };
in {
  # Downstream: `asgard.modules.home.example`, `asgard.modules.nixos.example`.
  flake.modules.home.example = homeOut;
  flake.modules.nixos.example = nixosOut;

  # Downstream: `asgard.homeModules.example-user`,
  # `asgard.homeModules.example-user-work`, `asgard.nixosModules.example-host`.
  flake.homeModules.example-user.imports = [users.example-user];
  flake.homeModules.example-user-work.imports = [users.example-user-work];
  flake.nixosModules.example-host.imports = [hosts.example-host];
}

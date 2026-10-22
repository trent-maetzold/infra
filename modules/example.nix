_: let
  # modules are reusable. They should contain the attrs and settings I want everywhere
  # this module is imported.
  homeOut = {};
  nixosOut = {};

  # users and hosts are concrete. They'll be imported as is by the makeHome or makeHost
  # functions.
  users = {
    example-user = {
      imports = [homeOut];
      email = "example@user.net";
    };
    example-user-work = {
      imports = [homeOut];
      email = "example.user@work.com";
    };
  };
  hosts = {
    example-host = {
      imports = [nixosOut];
    };
  };
in {
  # These get exported with the flake so that downstream can use them.
  flake.modules.home.example = homeOut;
  flake.modules.nixos.example = nixosOut;

  # We export the concrete, instantiated, not-reusable attrsets that will be imported
  # directly to a home config or host config.
  flake.homeModules.example-user.imports = [users.example-user];
  flake.homeModules.example-user-work.imports = [users.example-user-work];
  flake.nixosModules.example-host.imports = [hosts.example-host];
}

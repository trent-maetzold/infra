{
  vars.users.tm = {
    groups = ["wheel"];
    shell = "zsh";
    publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMZMIGNBlZ+VX528eFfwCmEuN4oQCigRA+FPwADzixds tm@hive";
    platform = "x86_64-linux";
    profiles = ["default" "data" "infra"];

    git = {
      name = "Trent Maetzold";
      email = "trent@maetzold.co";
    };
  };
}

# muninn's complete NixOS configuration; no shared repository modules. Args: preservation.
{
  lib,
  pkgs,
  preservation,
  ...
}: {
  imports = [preservation.nixosModules.default];

  hardware.facter.reportPath = ../facter.json;

  networking = {
    hostName = "muninn";
    networkmanager.enable = true;
  };

  boot = {
    initrd.systemd.enable = true;
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
  };

  users.users.trent = {
    isNormalUser = true;
    extraGroups = ["networkmanager" "wheel"];
  };

  services = {
    openssh.enable = true;
    userborn = {
      enable = true;
      passwordFilesLocation = "/persist/etc";
    };
  };

  security.sudo.wheelNeedsPassword = true;

  preservation = {
    enable = true;
    preserveAt."/persist" = {
      directories = [
        "/etc/NetworkManager/system-connections"
        "/etc/nixos"
        "/var/lib/bluetooth"
        "/var/lib/nixos"
        "/var/lib/systemd"
        "/var/log"
      ];
      files = [
        {
          file = "/etc/machine-id";
          inInitrd = true;
        }
        {
          file = "/etc/ssh/ssh_host_ed25519_key";
          how = "symlink";
          configureParent = true;
        }
        {
          file = "/etc/ssh/ssh_host_rsa_key";
          how = "symlink";
          configureParent = true;
        }
      ];
    };
  };

  systemd.suppressedSystemUnits = ["systemd-machine-id-commit.service"];

  environment.systemPackages = with pkgs; [
    git
    vim
  ];

  nix.settings.experimental-features = ["nix-command" "flakes"];
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  system.stateVersion = "26.05";
}

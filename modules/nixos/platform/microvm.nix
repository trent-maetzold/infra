# MicroVMs on this host, each alone on its own bridge: `10.66.<index>.0/24`,
# the host at .1 and the guest at .10, and no uplink on the bridge. The host
# routes, so a guest gets the internet and nothing nearer — not the LAN, not the
# tailnet, not the host, not another guest. A service opens the one thing its
# guest needs in `networking.firewall.extraForwardRules`.
{config, ...}: let
  nixos = {
    config,
    lib,
    microvm,
    ...
  }: let
    inherit (lib) mkIf;

    cfg = config.my.microvms;
    names = lib.attrNames cfg.guests;

    # `makeHost` puts the LAN behind br0; that is also the way out.
    egress = "br0";

    bridge = name: "mv-${name}";
    subnet = vm: "10.66.${toString vm.index}";
    mac = vm: "02:66:${lib.fixedWidthString 2 "0" (lib.toLower (lib.toHexString vm.index))}:00:00:01";

    # Everything a guest must never reach: the LAN, the guests' own subnets, the
    # tailnet, link-local.
    private = "{10.0.0.0/8, 172.16.0.0/12, 192.168.0.0/16, 100.64.0.0/10, 169.254.0.0/16}";

    # The host's stateVersion: the guest is the same release.
    stateVersion = config.system.stateVersion;

    guest = name: vm: {
      imports = [vm.guest];

      system.stateVersion = stateVersion;

      networking = {
        hostName = lib.mkDefault name;
        enableIPv6 = false;
        useDHCP = false;
        useNetworkd = true;
      };

      systemd.network.networks."10-eth0" = {
        matchConfig.Name = "eth0";
        address = ["${subnet vm}.10/24"];
        routes = [{Gateway = "${subnet vm}.1";}];
        dns = ["1.1.1.1"];
      };

      microvm = {
        inherit (vm) mem vcpu;

        hypervisor = "qemu";

        interfaces = [
          {
            type = "bridge";
            id = "net0";
            bridge = bridge name;
            mac = mac vm;
          }
        ];

        shares = [
          {
            proto = "9p";
            tag = "ro-store";
            source = "/nix/store";
            mountPoint = "/nix/.ro-store";
          }
        ];
      };
    };
  in {
    imports = [microvm.nixosModules.host];

    options.my.microvms.guests = lib.mkOption {
      type = lib.types.attrsOf (lib.types.submodule {
        options = {
          index = lib.mkOption {
            type = lib.types.ints.between 1 254;
            description = "Third octet of the guest's bridge, its subnet.";
          };

          mem = lib.mkOption {
            type = lib.types.ints.positive;
            default = 1024;
            description = "RAM in megabytes.";
          };

          vcpu = lib.mkOption {
            type = lib.types.ints.positive;
            default = 2;
            description = "Virtual CPUs.";
          };

          guest = lib.mkOption {
            type = lib.types.deferredModule;
            description = "The guest's own modules: what runs on the machine, never its plumbing. Extra arguments come from `microvm.specialArgs`.";
          };
        };
      });
      default = {};
    };

    config = mkIf (names != []) {
      # `name` is also the hostname and the state directory.
      microvm.vms = lib.mapAttrs' (name: vm: lib.nameValuePair name {config = guest name vm;}) cfg.guests;

      networking = {
        bridges = lib.mapAttrs' (name: _: lib.nameValuePair (bridge name) {interfaces = [];}) cfg.guests;

        interfaces = lib.mapAttrs' (name: vm:
          lib.nameValuePair (bridge name) {
            ipv4.addresses = [
              {
                address = "${subnet vm}.1";
                prefixLength = 24;
              }
            ];
          })
        cfg.guests;

        nat = {
          enable = true;
          internalInterfaces = map bridge names;
          externalInterface = egress;
        };

        firewall = {
          # Out, but never private.
          extraForwardRules =
            lib.concatMapStrings (name: ''
              iifname "${bridge name}" oifname "${egress}" ip daddr != ${private} accept
            '')
            names;

          # Nor into the host: only the answers to what the guest started.
          extraInputRules =
            lib.concatMapStrings (name: ''
              iifname "${bridge name}" drop
            '')
            names;
        };
      };

      # qemu's bridge helper attaches only to the bridges libvirt allows.
      virtualisation.libvirtd.allowedBridges = map bridge names;
    };
  };
in {
  # Features
  features.nixos.platform.microvm = nixos;
}

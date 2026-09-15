# Asgard

Opinionated NixOS + home-manager defaults. Not a system — a module set.

Asgard is the layer above [Midgard](https://github.com/tm/hearthworks): it
ships the defaults, Midgard ships the hosts, users, secrets and anything
that differs per deployment. Asgard knows nothing about any user, host or
infra.

## Consuming it

```nix
inputs.asgard.url = "github:tm/asgard";

# module args (specialArgs): lazyvim, home-manager, nixos-wsl, disko-zfs
# pkgs needs the llm-agents overlay: llm-agents.overlays.shared-nixpkgs
imports = [ asgard.nixosModules.default ];
```

## Rules

- Every setting is `lib.mkDefault` — a consumer can override any leaf.
- No `user`, no hostnames, no secrets, no paths outside this repo.
- Config files (`home/config/*`) are part of the defaults; anything that
  differs per deployment lives in the consumer.

## Docs

```sh
nix build .#options-commonmark   # every option, rendered with defaults
nix build .#options-json         # machine-readable
```

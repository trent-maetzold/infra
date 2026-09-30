# Asgard

Opinionated NixOS + home-manager defaults. A module set, not a system: hosts,
users, and secrets belong to the consuming flake.

## Consuming

```nix
inputs.asgard.url = "git+https://codeberg.org/trkm/asgard";

# module args the modules read: lazyvim, home-manager, nixos-wsl
specialArgs = asgard.inputs // inputs;

# nixpkgs overlay the modules expect (llm-agents)
overlays = [asgard.overlays.default];

imports = [asgard.nixosModules.default];      # NixOS
imports = [asgard.homeManagerModules.default]; # standalone home-manager
```

Every setting is overridable: `mkDefault` on leaves, `mkAfter` for lists.

## Commands

```sh
nix fmt                          # format (alejandra)
nix flake show                   # outputs
nix flake check                  # evaluate and run checks
nix build .#options-commonmark   # every option, rendered with defaults
nix build .#options-json         # machine-readable options
```

Reviewing a rebuild diff, from a host config:

```sh
nh home build -d always   # package diff; needs nvd on PATH
nh os build -d always
nix store diff-closures /run/current-system ./result  # zero extra tools
```

## Docs

Desired policy and conventions live in AGENTS.md; known out-of-spec items in
TODO.md.

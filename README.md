# Asgard

Opinionated NixOS + home-manager defaults and the configurations that use them
(flake-parts, dendritic: every file under `apps/`, `configurations/`, `lib/`,
`modules/`, `packages/` is auto-imported by import-tree).

- `modules/`: reusable, user- and host-independent capabilities and defaults.
- `configurations/`: hosts, users, deployment, identity. Secrets live in the
  private `secrets` flake input.

## Consuming

```nix
inputs.asgard.url = "git+https://codeberg.org/trkm/asgard";

imports = [asgard.nixosModules.default]; # NixOS; inputs are captured, no specialArgs
imports = [asgard.homeModules.default];  # home-manager, every feature
nixpkgs.overlays = [asgard.overlays.default];
```

Profiles: `nixosModules.{default,wsl,nvidia}`, `homeModules.default`. Single features
are `features.{nixos,home}.<domain>.<feature>` (e.g. `home.lang.nix`):
importing one enables it. Override with `lib.mkForce`.

## Commands

```sh
nix fmt                          # format (alejandra)
nix flake show                   # outputs
nix flake check                  # evaluate and run checks
colmena apply --on heimdall  # deploy (never from CI)
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

Desired policy and conventions live in AGENTS.md.

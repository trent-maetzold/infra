# Asgard

Reusable NixOS, Home Manager and infrastructure configuration. Asgard owns
configuration logic; the consumer owns hosts, identity, layouts and secrets.

## Consuming

```nix
{
  inputs.asgard.url = "git+https://codeberg.org/trkm/asgard";

  outputs = {asgard, ...}: {
    nixosConfigurations.example = asgard.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [asgard.nixosModules.defaults ./hosts/example.nix];
    };

    homeConfigurations.example = asgard.lib.mkHome {
      system = "x86_64-linux";
      modules = [
        asgard.homeManagerModules.development
        {
          home = {
            username = "example";
            homeDirectory = "/home/example";
            stateVersion = "26.05";
          };
        }
      ];
    };
  };
}
```

- `nixosModules.default` and `homeManagerModules.default` register the opt-in
  catalogs. Importing them does not enable Asgard features.
- `nixosModules.defaults` selects base NixOS and Home Manager wiring defaults.
- `homeManagerModules.defaults` selects base home, Git, SSH and shell defaults.
- `homeManagerModules.development` adds language tooling and LazyVim.
- `nixosModules.wsl` registers WSL and its tuning; set `wsl.enable` and
  `wsl.defaultUser` downstream.

Modules capture their upstream dependencies and install the required overlay;
consumers need no dependency `specialArgs` bag. The NixOS catalog registers Home
Manager and shares the home catalog with configured users; choose each user's
profile explicitly. `lib.nixosSystem` is the unchanged upstream constructor;
`lib.mkHome` supplies a package set from `system`, accepts a replacement `pkgs`,
and otherwise forwards Home Manager arguments. Both take explicit `modules`.

Consumers override settings at leaves and extend lists through ordinary module
merging. A consumer can disable any profile-selected feature with `enable = false`.

## Commands

```sh
nix fmt
nix flake show
nix flake check --no-build --all-systems
nix build .#checks.x86_64-linux.module-evaluation
nix build .#options-json
nix build .#options-commonmark
```

The integration check evaluates real NixOS toplevel and Home Manager activation
derivations, catalog defaults and consumer overrides. It does not build or
activate those systems. Both declared architectures are checked during
`--all-systems` evaluation; building architecture-specific outputs needs an
appropriate builder.

Reviewing a downstream rebuild:

```sh
nh home build -d always
nh os build -d always
nix store diff-closures /run/current-system ./result
```

## Refactor status

The foundation is implemented; downstream dependency consolidation, Quadlets,
Terranix, agent isolation, editor settings and Codeberg Pages publishing are
still in progress. The sourced contract is in [docs/refactor-design.md](docs/refactor-design.md);
the ownership and acceptance ledger is in [docs/migration-plan.md](docs/migration-plan.md).
[TODO.md](TODO.md) tracks the original work. Module conventions live in [AGENTS.md](AGENTS.md).

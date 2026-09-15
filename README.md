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

- `lib.mkDefault` on the leaves — a consumer overrides any leaf; `lib.mkMerge`
  for structure (parents stay plain, or priority filtering drops the whole
  subtree when another module defines the same parent). Exceptions:

  - append-style package lists (`home.packages`, `environment.systemPackages`,...)
    use `lib.mkAfter`: nixpkgs/home-manager define those at normal priority,
    and priority filtering silently drops a `mkDefault` list.
  - passthrough attrs (`nixpkgs.config.*`, `programs.ssh.settings`,
    `programs.starship.settings`, `programs.pi-coding-agent.settings`, the
    distrobox containers) take plain values: their readers see the override
    wrapper, not the value.
  - keys nixpkgs already defines plainly (`nix.settings.trusted-users`) use
    `mkAfter` so both survive.
- No `user`, no hostnames, no secrets, no paths outside this repo.
- Config files (`home/config/*`) are part of the defaults; anything that
  differs per deployment lives in the consumer.

## Docs

```sh
nix build .#options-commonmark   # every option, rendered with defaults
nix build .#options-json         # machine-readable
```

## Module conventions

- Plain `.nix` files. No flake inputs in scope, no closures, no in-file
  `imports` (the flake lists are the only wiring).
- Canonical shapes, in order of preference:
  - Gateway already exists upstream → unconditional settings (no module
    `config` wrapper at all):
    ```nix
    { config, lib, pkgs, ... }: {
      services.openssh.settings = {
        PermitRootLogin = "no";
        PasswordAuthentication = false;
      };
    }
    ```
  - Own effect that needs a flag → keep both top-level (module system
    rejects a bare top-level attrset next to `config`/`options` keys):
    ```nix
    { config, lib, pkgs, ... }: {
      config = lib.mkMerge [
        { services.podman.quadlet... = ...; }                   # upstream-gated: unconditional
        (lib.mkIf config.services.podman.enable {                # own effect: gated
          services.podman.containers.example = { ...; };          # no identity here
        })
      ];
    }
    ```
  - No upstream flag exists → declare a module-local option inline
    (`services.llama-swap.cuda.enable`, ...).
- Options are declared where they're used; no central options file.
- Nested settings are combined into one attrset, never sibling dotted
  paths: `deployment = { targetHost = ...; targetUser = ...; };`.
- Flags default on (`lib.mkDefault true` on top of the gate).
- Comments are rare: they state a non-obvious constraint, never what changed
  from the last version (that belongs in the commit message).
- Enable flags are never defined inside the module that reads them.
- Shared modules never take the `user` specialArg or set per-host identity
  options (`wsl.defaultUser`, `home.stateVersion`, ...) — those live in
  `hosts/<name>/default.nix`.
- Shared modules never reference secrets or agenix (`age.*`,
  `secrets/*.age`) — only the `ragenix` CLI install; delivery is the hive's
  `deployment.keys`.


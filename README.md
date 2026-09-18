# Asgard

Opinionated NixOS + home-manager defaults. Not a system — a module set.

Asgard is the layer above [Midgard](https://github.com/tm/hearthworks): it
ships the defaults, Midgard ships the hosts, users, secrets and anything
that differs per deployment. Asgard knows nothing about any user, host or
infra.

## Consuming it

```nix
inputs.asgard.url = "github:tm/asgard";

# nixpkgs carrying the overlay the modules expect (llm-agents)
pkgs = import asgard.inputs.nixpkgs {
  inherit system;
  overlays = [ asgard.overlays.default ];
};

# module args (specialArgs) the modules read: lazyvim, home-manager, nixos-wsl
imports = [ asgard.nixosModules.default ];
```

## Rules

**Overridable settings go on leaves.** `lib.mkDefault` does not mean
"additive default" — it means *this definition loses to any other definition
of the same option* (priority 1000 versus the normal 100). Put it on a parent
attrset and the whole subtree becomes one definition, so if anything else
defines that same parent, your entire block is discarded. Put it on a leaf
and only that leaf yields; every other leaf keeps merging.

```nix
services.openssh.settings = {              # parent: plain
  PermitRootLogin = lib.mkDefault "no";    # leaf: overridable, everything else merges
};
```

`lib.mkMerge` is unrelated to priority — it is just how several config
fragments (usually with `lib.mkIf`) are combined.

**Package lists use `lib.mkAfter`.** For list options the module system keeps
only the highest-priority definitions, and nixpkgs / home-manager define
`home.packages` and `environment.systemPackages` at normal priority. An
`mkDefault` list would be outranked and silently dropped, so asgard's `jq`,
`just` and `tree` would disappear the moment anything else added a package.
`mkAfter` keeps the definition at normal priority and appends it last, so it
always merges: nixpkgs' packages + asgard's + downstream additions. Only an
`lib.mkForce` replaces the list — asgard uses one, on the distrobox
`containers.ini` file, because home-manager generates that same file from
`programs.distrobox.containers`; deployments customise the option, not the
file.

**Passthrough attrs stay plain.** Some options are declared as "anything
goes" bags whose values are read directly by other modules rather than merged
per key: `nixpkgs.config.*`, `programs.ssh.settings`,
`programs.starship.settings`, `programs.pi-coding-agent.settings`, the
distrobox containers. Write them plainly; where the leaves inside them are
ordinary options, those leaves can still be `mkDefault`. A default on the
whole bag buys nothing: it is dropped the moment a deployment defines anything
in that option, and takes the sibling defaults with it (downstream
`s.k.a = "down"` against `s.k = lib.mkDefault { a = "x"; ty = "y"; }` leaves
`ty` at the option's own default, while `s.k.ty = lib.mkDefault "y"` keeps
it), and in shapes where the merge does keep the wrapper it reaches the reader
as `{ _type = "override"; ... }`. A key written plainly there is a permanent
definition though: a deployment that wants a different value for that same key
would hit a same-priority conflict and need `mkForce`, and `mkDefault` cannot
rescue it — so asgard only writes keys in those bags that no deployment is
expected to redefine.

**Keys nixpkgs already sets go through `mkAfter`.** `lib.mkDefault` yields to
*any* other definition, so a default that nixpkgs also sets (for example
`nix.settings.trusted-users = [ "root" ]`) would silently lose asgard's
value. `mkAfter` merges instead, giving `[ "root" "@wheel" ]`.

- No `user`, no hostnames, no secrets, no paths outside this repo.
- Config files (`home/config/*`) are part of the defaults; anything that
  differs per deployment lives in the consumer.

## Docs

```sh
nix build .#options-commonmark   # every option, rendered with defaults
nix build .#options-json         # machine-readable
```

## hermes-agent

Runs on a host, microvm, or NixOS container — never the upstream container
mode (asserted). Preset MCP servers for the usual self-hosted assistants
take their secrets as `${VAR}` placeholders resolved from the service env
(`services.hermes-agent.environmentFiles`), never inline:

```nix
services.hermes-agent = {
  enable = true;
  assistant.mcpServers = { gmail.enable = true; arrs.enable = true; };
  environmentFiles = [ /var/lib/secrets/hermes.env ];  # SONARR_URL=... etc.
  settings.toolsets = [ "all" ];                        # incl. homeassistant toolset
  settings.web.search_backend = "searxng";              # when SEARXNG_URL is set
};
```

SABnzbd has no published npx/uvx stdio server — hermes-webui talks to it
natively, or run `ghcr.io/ltmarx/sabnzbd-mcp` and add a plain `mcpServers`
entry with `command = "docker"`.

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


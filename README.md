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

**Rootless pasta publishes IPv4 only** (`modules/podman.nix`). With IPv6 in
play the port relay binds an address the host — or WSL — cannot reach, so the
container's published port goes nowhere: `pasta_options = [ "--ipv4-only" ]`,
as `mkAfter` so a deployment's own pasta flags still merge.

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

One shape in every module — the file says out loud what turns it on:

```nix
{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.programs.zsh;
in {
  imports = [./other.nix];                        # only when there are any

  config = lib.mkMerge [
    {programs.zsh.enable = lib.mkDefault true;}   # asgard owns the flag
    (lib.mkIf cfg.enable {                        # everything else is the effect
      programs.zsh.syntaxHighlighting.enable = lib.mkDefault true;
    })
  ];

  options.languages.bash.enable = lib.mkEnableOption "…";  # only when asgard declares it
}
```

- Plain `.nix` files: no flake inputs in scope, no `import` of another
  module's option set — the flake's `imports` lists are the wiring. The two
  entry modules (`modules/default.nix`, `home/modules/default.nix`) are the
  unconditional base: they default options someone else owns and have no gate.
- `cfg` is the subtree the module owns; the gate is always `cfg.enable`, and
  one module has one gate. A module that needs a second enable flag is two
  modules. Sub-conditions of its own gate are not a second gate
  (`hardware.nvidia-container-toolkit.enable` inside `wsl`, `containers != {}`
  inside `distrobox`).
- Where the flag is upstream's (`programs.zsh.enable`,
  `virtualisation.podman.enable`, `services.llama-swap.enable`, …) asgard only
  reads it: the consumer opts in. Where asgard declares it, asgard defaults it
  on — `lib.mkDefault true`, next to the gate, never inside it.
- `imports` first, one blank line after it.
- Top-level attrs alphabetical (`config` before `options`), nested sets too,
  except where order is semantics: `imports`, `environment.systemPackages`.
- `let` between the function head and the module's `{`; the bindings read as
  one list and bind whole subtrees (`cfg = config.programs.distrobox;`) rather
  than naming a path per reference.
- Dotted keys when the set holds one value (`home.shellAliases.ld = …`), nesting
  when it holds several.
- Blank line between two attrset values, never inside a list.
- The shape is what `nix fmt` produces — never hand-wrap an argument list.
- No comments in the config: the why belongs in the commit message, and a rule
  or a trap that has to survive belongs in this file. Exceptions are `lib/` and
  `overlays/` (their header states the contract the file encodes) and
  `home/config/*`, which is content.
- Options are declared where they're used; no central options file.
- Shared modules never take the `user` specialArg or set per-host identity
  options (`wsl.defaultUser`, `home.stateVersion`, ...) — those live in
  `hosts/<name>/default.nix`.
- Shared modules never reference secrets or agenix (`age.*`,
  `secrets/*.age`) — only the `ragenix` CLI install; delivery is the hive's
  `deployment.keys`.


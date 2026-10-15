# AGENTS.md

Asgard is a reusable NixOS + home-manager module set. It ships defaults; the
consuming flake ships hosts, users, and secrets. Build and check commands live
in README.md.

## Structure

Dendritic flake-parts: `flake.nix` loads `apps/`, `configurations/`, `lib/`,
`modules/`, `options/`, `packages/`, `vars/` with import-tree; each file registers its own `flake.*`
outputs and adds itself to the `default` profiles. No relative imports (data
paths like `./config` excepted): reach other files through `config.flake.*`.
`modules/` is reusable and consumer-independent; anything tied to a user or host
lives in `configurations/{hosts,users}/`. `vars/` is data only (`vars.stateVersion`,
`vars.hosts`, `vars.users`, ...): all PII and infra identity lives there, and
consumers read `config.vars` and format it. `configurations/{hosts,users}/base.nix` map
`vars.hosts`/`vars.users` (an inventory: no lets or loops) into modules,
configurations and colmena nodes; a host lists its `users` and `profiles`, a
user its `profiles`. Host-coupled features add themselves to
`flake.nixosModules.<host>`; there are no collectors. Packages live in `packages/`: each module sets `flake.overlays.<name>` and
`perSystem.packages`; consumers apply `attrValues flake.overlays`
and `nixosModules.default` applies it.

Use GitNexus for structure (`gitnexus analyze`, then `query`/`context`/`impact`)
instead of a hand-maintained tree. `.gitnexus/` is local and gitignored.

## Dendritic modules

Every module is one feature at `features.{nixos,home}.<domain>.<feature>` (typed
in `options/`). Files sit in matching folders. Home domains: `base editor
lang vcs ai containers`; NixOS: `base
hardware network platform ai`; `modules/shared/` holds features that register on both
sides in one file (`base.nix`, `packages/<group>.nix`). `base` is a domain of
features every config imports; `core` is a feature, a domain's leftover
essentials (`base.core`, `lang.core`). Host-only
features use the host as domain (`features.nixos.heimdall.caddy`). Shared helpers
are `flake.lib.<fn>`.

- Plain values only. No `enable` options, gates, `mkDefault`, or `mkAfter`:
  importing a feature enables it.
- Profiles (`flake.homeModules.*`, `flake.nixosModules.*`, registered empty in
  `options/profiles.nix`) are just `imports` of features. `homeModules.default`
  is everything; `nixosModules.default` only what every host needs.
- Hosts and users pull profiles only, via `vars`; features join profiles. Never
  name a host or user from `modules/`, and never import a single feature from
  `vars/` or `base.nix`: deleting a feature must drop it silently, not break
  eval. Push back on requests that break this.
- `base.nix` glue only reacts (`mkIf config.programs.git.enable`); enabling is
  a feature's job.
- Consumers override with `lib.mkForce` or by not importing.
- Upstream flags (`programs.git.enable`) are set by the feature that needs them.
  A feature needing another imports it.

```nix
{config, ...}: let
  git = {pkgs, ...}: {
    programs.git.enable = true;
    programs.gh.enable = true;
    home.packages = [pkgs.forgejo-cli];
  };
in {
  features.home.vcs.git = git;
  flake.homeModules.default.imports = [config.features.home.vcs.git];
}
```

- A feature's own tools stay in it. Package lists serving a domain or several
  features live in `shared/packages/<name>.nix` as
  `features.{nixos,home}.packages.<name>`; features import them, or they join a profile of
  their own name (`homeModules.infra`).
- Keep the module function inline in `let`; one feature per file.
- Dotted keys when the set holds one value, nesting when several. Blank line
  between attrsets, never inside a list. `nix fmt` is the shape.
- Modules never take a `user` specialArg, host identity, or secrets; secret
  delivery is downstream.

## Config as nix

Defaults live in Nix, not config files. `home/config/` shrinks toward nothing:
Nvim Lua becomes lazyvim config attrs, LSP configs move to their `lang`
module, pi configs become Nix. Only content that cannot be expressed as Nix
attributes survives (currently the root AGENTS.md).

## Code style

- Formatted with Alejandra, which does not settle newline whitespace — keep it
  consistent.
- Attr and arg ordering stays consistent: hierarchical (config > lib > pkgs)
  when importance decides, alphabetical when it reads better.
- Plain attrsets over complicated functional forms. When a function is
  unavoidable, pull it into `lib/` — except patterns every community flake
  defines in place (`forAllSystems`, `pkgsFor`): those belong in the flake.
- Prefer mature, robust flakes over hand-rolled equivalents when they make this
  flake easier to read or edit.

## Brevity

- Comments: only the non-obvious, as short as needed. Why a change was made is
  a commit message.
- Code: as short as needed. No inline nested bash; rethink the approach.

## Ponytail

The active skill's laziness is house style, with one exception: prefer a mature
library over hand-rolled code even when it adds a dependency — less code to
read and maintain wins.

More lines are the failure mode. Agents get code working but bloat it: re-read
every edit and collapse what fits on one line.

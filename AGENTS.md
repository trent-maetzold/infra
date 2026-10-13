# AGENTS.md

Asgard is a reusable NixOS + home-manager module set. It ships defaults; the
consuming flake ships hosts, users, and secrets. Build and check commands live
in README.md.

## Structure

Dendritic flake-parts: `apps/`, `configurations/`, `lib/`, `modules/`, `packages/`
are auto-imported by Haumea; each file registers its own `flake.*` outputs and
merges into the `default` roles. `_`-prefixed files are skipped (imported by
siblings). `modules/` is reusable and consumer-independent; anything tied to a
user or host lives in `configurations/`, gated with `lib.mkIf` on the feature's
enable option. Packages and their overlays live together in `packages/`.

Use GitNexus for structure (`gitnexus analyze`, then `query`/`context`/`impact`)
instead of a hand-maintained tree. `.gitnexus/` is local and gitignored.

## Dendritic modules

Every module is one feature: `flake.modules.<class>.<feature>`, `<feature>` the
path joined by `-`. Classes: `nixos`, `homeManager` (not `home`; home-manager
rejects it). Typed by `flake-parts.flakeModules.modules`.

- Plain values only. No `enable` options, gates, `mkDefault`, or `mkAfter`:
  importing a feature enables it.
- Profiles (`flake.homeModules.default`, `flake.nixosModules.{default,wsl,nvidia}`)
  are just `imports` of features. `homeModules.default` is everything;
  `nixosModules.default` only what every host needs.
- Consumers pick features (hosts and users in `configurations/` do the same),
  and override with `lib.mkForce` or by not importing.
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
  flake.modules.homeManager.git = git;
  flake.homeModules.default.imports = [config.flake.modules.homeManager.git];
}
```

- Keep the module function inline in `let`; one feature per file.
- Dotted keys when the set holds one value, nesting when several. Blank line
  between attrsets, never inside a list. `nix fmt` is the shape.
- Modules never take a `user` specialArg, host identity, or secrets; secret
  delivery is downstream.

## Config as nix

Defaults live in Nix, not config files. `home/config/` shrinks toward nothing:
Nvim Lua becomes lazyvim config attrs, LSP configs move to their `languages`
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

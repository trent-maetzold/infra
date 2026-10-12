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

## Overridability

The consumer wins every conflict; that is what `mkDefault`/`mkAfter` are for.

- Overridable settings go on leaves. `mkDefault` loses to any other definition
  of that option, so a parent attrset becomes one definition and is discarded
  wholesale.
- List options use `mkAfter` (packages, pattern lists). `mkDefault` on a list
  loses the whole list to any consumer definition — no concatenation — while
  `mkAfter` appends. Use `mkAfter` for keys nixpkgs already sets too
  (`nix.settings.trusted-users`).
- `mkMerge` combines fragments; it has nothing to do with priority.
- Passthrough bags stay plain and are read directly, not merged per key
  (`nixpkgs.config.*`, `programs.ssh.settings`, `programs.starship.settings`,
  `programs.pi-coding-agent.settings`, distrobox containers). Only write keys
  no deployment is expected to redefine; a plain key is a same-priority
  conflict for anyone who does.

## Module conventions

```nix
{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.languages.bash;
in {
  imports = [./other.nix]; # only when there are any

  config = lib.mkMerge [
    {languages.bash.enable = lib.mkDefault true;}
    (lib.mkIf cfg.enable {
      home.packages = lib.mkAfter (with pkgs; [shellcheck]);
    })
  ];

  options.languages.bash.enable = lib.mkEnableOption "bash language support";
}
```

- Each module file is a flake-parts module registering `flake.<class>Modules.<name>`
  (name = path joined by `-`) around the plain module shown here; the default
  roles merge them automatically. Inputs come from the flake-level `inputs`.
- One module, one gate. `cfg` is the subtree the module owns; the gate is
  always `cfg.enable`. A second enable flag means two modules. Sub-conditions
  of its own gate are not a second gate.
- Modules are imported unconditionally; the gate is `lib.mkIf cfg.enable` on
  `config`. Never gate `imports` — conditionally imported modules hide their
  options from search and generated docs.
- Asgard-declared flags default on: `lib.mkDefault true` next to the gate,
  never inside it. Upstream flags (`programs.zsh.enable`) are only read.
- `mkEnableOption` text is a lowercase noun phrase naming what it turns on, no
  articles or host names: `"bash language support"`.
- `imports` first, blank line after. `let` sits between the function head and
  the module body and binds whole subtrees (`cfg = config.programs.distrobox`).
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

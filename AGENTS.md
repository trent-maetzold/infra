# AGENTS.md

Asgard is a reusable NixOS + home-manager module set. It exports an opt-in
catalog and explicit defaults profiles; the consumer owns hosts, identity,
infrastructure state and secrets. Build and check commands live
in README.md.

## Structure

All Nix lives under `nix/`, except root `flake.nix` and `flake.lock`.
import-tree scans module-only directories; private helpers use underscore
paths, and profiles stay outside scanned roots. flake-parts owns system loops.

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
  (`nix.settings.trusted-users`). Overlays use `mkBefore`: later overlays win.
- `mkMerge` combines fragments; it has nothing to do with priority.
- Check upstream option types before assuming per-key merging. Values read
  directly rather than merged through options (`nixpkgs.config.*`) stay plain.
  Prove consumer overrides with real evaluation and generated-config checks.

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

  config = lib.mkIf cfg.enable {
    home.packages = lib.mkAfter (with pkgs; [shellcheck]);
  };

  options.languages.bash.enable = lib.mkEnableOption "bash language support";
}
```

- One module, one gate. `cfg` is the subtree the module owns; the gate is
  always `cfg.enable`. A second enable flag means two modules. Sub-conditions
  of its own gate are not a second gate.
- Modules are imported unconditionally; the gate is `lib.mkIf cfg.enable` on
  `config`. Never gate `imports` — conditionally imported modules hide their
  options from search and generated docs.
- Catalog flags default off. Profiles select features with `lib.mkDefault true`
  on enable leaves; modules read their own gate, including upstream gates.
- `mkEnableOption` text is a lowercase noun phrase naming what it turns on, no
  articles or host names: `"bash language support"`.
- `imports` first, blank line after. `let` sits between the function head and
  the module body and binds whole subtrees (`cfg = config.programs.distrobox`).
- Dotted keys when the set holds one value, nesting when several. Blank line
  between attrsets, never inside a list. `nix fmt` is the shape.
- Identity, endpoints and credential paths are module options, not a shared
  `specialArgs` bag. Capture dependencies in the defining flake. Secret contents
  and delivery stay downstream; emit credential-dependent attributes only when
  the feature is enabled and the credential is supplied.

## Config as nix

Defaults live in Nix, not config files. `nix/home/config/` shrinks toward nothing:
Nvim Lua becomes lazyvim config attrs, LSP configs move to their `languages`
module, pi configs become Nix. Only content that cannot be expressed as Nix
attributes survives (currently the root AGENTS.md).

## Code style

- Formatted with Alejandra, which does not settle newline whitespace — keep it
  consistent.
- Attr and arg ordering stays consistent: hierarchical (config > lib > pkgs)
  when importance decides, alphabetical when it reads better.
- Plain attrsets over complicated functional forms. Reusable construction
  helpers live in `nix/lib`; flake-parts handles per-system outputs.
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

<!-- gitnexus:start -->
# GitNexus — Code Intelligence

This project is indexed by GitNexus as **asgard** (125 symbols, 123 relationships, 0 execution flows).

> Index stale? Run `node .gitnexus/run.cjs analyze --index-only` from the project root — it auto-selects an available runner. No `.gitnexus/run.cjs` yet? Bootstrap with `npx`, `bunx`, or `pnpm dlx` — e.g. `bunx gitnexus@latest analyze` (npm 11 npx crash; #1939).

## Always Do

- **MUST run impact before editing.** Use `impact({target: "symbolName", direction: "upstream"})` or `node .gitnexus/run.cjs impact "symbolName" --direction upstream --repo .`; report callers, processes, and risk. Never substitute grep for graph analysis.
- **MUST analyze graph changes before committing.** Use `detect_changes({scope: "all"})` (MCP) or `node .gitnexus/run.cjs detect-changes --scope all --repo .` (CLI fallback). `partial: true` or `truncated: true` is not a clean check — a zero means unseen, not unaffected; re-run it. For regression review: `detect_changes({scope: "compare", base_ref: "main"})` or `node .gitnexus/run.cjs detect-changes --scope compare --base-ref "main" --repo .`.
- MUST warn on HIGH/CRITICAL `risk` pre-edit; never use `riskSharedAxes` to waive a HIGH/CRITICAL `risk` warning. Compare File/symbol: MCP File omits axes; Graph-RAG expands File.
- **MUST treat `risk: UNKNOWN` as unresolved, not as low.** An empty caller set is not evidence the symbol is unused — it can also mean the callers are not resolvable by the index (plain-object property access, dynamic dispatch, cross-language calls). `impact` pairs `UNKNOWN` with a `riskNote` saying so. Confirm with a text search before treating the symbol as safe to change or delete; do not proceed on the strength of a zero.
- **MUST use `query({search_query: "concept"})` for concepts/flows, `context({name: "symbolName"})` for a named symbol, or `impact` for blast radius, on read-only callers, dependencies, imports, or execution flow.** Graph first; text search only for empty/`UNKNOWN`/literals.
- For security review, `explain({target: "fileOrSymbol"})` lists taint findings (source→sink flows; needs `analyze --pdg`).

## Never Do

- NEVER edit a function, class, or method before MCP/CLI impact analysis.
- NEVER ignore HIGH or CRITICAL risk warnings from impact analysis, and never read `UNKNOWN` as an all-clear — it means the walk could not answer, which is the one verdict that requires confirming by other means.
- NEVER rename symbols with find-and-replace — use `rename` which understands the call graph.
- NEVER commit before MCP/CLI graph change analysis.

## Resources

| Resource | Use for |
| --- | --- |
| `gitnexus://repo/asgard/context` | Codebase overview, check index freshness |
| `gitnexus://repo/asgard/clusters` | All functional areas |
| `gitnexus://repo/asgard/processes` | All execution flows |
| `gitnexus://repo/asgard/process/{name}` | Step-by-step execution trace |

## CLI

| Task | Read this skill file |
| --- | --- |
| Understand architecture / "How does X work?" | `.claude/skills/gitnexus-exploring/SKILL.md` |
| Blast radius / "What breaks if I change X?" | `.claude/skills/gitnexus-impact-analysis/SKILL.md` |
| Trace bugs / "Why is X failing?" | `.claude/skills/gitnexus-debugging/SKILL.md` |
| Rename / extract / split / refactor | `.claude/skills/gitnexus-refactoring/SKILL.md` |
| Tools, resources, schema reference | `.claude/skills/gitnexus-guide/SKILL.md` |
| Index, status, clean, wiki CLI commands | `.claude/skills/gitnexus-cli/SKILL.md` |

<!-- gitnexus:end -->

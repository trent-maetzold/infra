# TODO

Known out-of-spec items. AGENTS.md is desired policy, not current state.

## Blockers

- [x] Fix the deleted Pi/agent-config references and include the Pi module in
      flake-visible sources. Real Home Manager activation evaluation passes.

## Structure

- [x] Restructure to `nix/{modules,home,lib,overlays}` with scoped import-tree;
      only `flake.nix` and `flake.lock` remain as root Nix files.
- [x] Replace `forAllSystems`/`pkgsFor` with flake-parts `systems`/`perSystem`.
- [x] Adopt flake-parts idioms. A direct flake-utils dependency is deliberately
      omitted: it duplicates the same system loop. Upstream flakes may retain it.
- [ ] Import ragenix here; secret delivery stays downstream.
- [x] Separate opt-in catalogs from defaults/development profiles. Consumer
      disable/override checks pass without adding a second profile framework.

## Config as nix

- [ ] Retire `nix/home/config/`: nvim Lua to lazyvim config attrs, pyright and
      rust-analyzer configs to their `languages` modules, pi package configs to
      Nix, hardcoded skills removed. Root AGENTS.md is the only survivor.
- [ ] Add agent skills via agent-skills-nix + npins
      (github.com/Kyure-A/agent-skills-nix, github.com/andir/npins).

## Agents

- [ ] Move coding agents into NixOS containers; only pi and hermes.
- [ ] Add the hermes-agent module the same way.
- [ ] MCP servers configured once, no credentials here: placeholders pointing
      at the credential location (env files downstream), per-server enable
      toggle, mcp-cli as the entrypoint.
- [ ] De-duplicate overlapping pi plugins.

## Engineering

- [ ] Add a protobuf language module with LSP and formatter.
- [ ] Better nix LSP or settings; suggestions are sparse.
- [ ] Every LSP lives in `languages/` modules, wired for pi-lens.
- [ ] Fix the nvim `jk` key combo.

## Docs

- [ ] Generate option docs in CI and publish to a hosted site.

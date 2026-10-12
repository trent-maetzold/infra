# TODO

Known out-of-spec items. AGENTS.md is desired policy, not current state.

## Blockers

- [ ] `home/modules/agents/default.nix` imports `./pi.nix`, which is deleted
      (now `./pi/`, untracked). Fix the import and `git add home/modules/agents/pi/`;
      `nix flake check` fails until then because flakes only see tracked files.

## Structure

- [x] Dendritic flake-parts + Haumea layout (supersedes nix/ restructure, import-tree, flake-parts).
- [ ] Import ragenix here; secret delivery stays downstream.
- [ ] Evaluate profiles/suites if `asgard.enable` grows complex.

## Config as nix

- [ ] Retire `home/config/`: nvim Lua to lazyvim config attrs, pyright and
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

# AGENTS.md

Asgard: reusable NixOS + home-manager features. Consumers bring hosts, users and
secrets. Commands are in README.md.

## Before you edit

1. Run `gitnexus analyze`, then `query`/`context`/`impact` to find code. No
   hand-kept tree.
2. Read the file you are changing and one neighbour; copy their shape.
3. After editing: `nix fmt`, evaluate every `nixosConfigurations.<h>` and
   `legacyPackages.x86_64-linux.homeConfigurations.tm`, then
   `nix flake check --no-build`.

## Where things go

- `modules/<domain>/<feature>.nix`: one feature, exported as
  `flake.modules.{nixos,homeManager}.<feature>`; dirs only organize, names are
  flat (subfeatures use dashes: `pi-zentui`). Generic parts never name a host
  or user.
- `lib/`: the consumer contract only (`makeUser`, `makeHost`, `makeDeploymentKey`).
- A feature's own options and functions live with it: `ai/agents/rules.nix`
  declares `agents.md` and `makeAgentRules`.
- `options/`: global flake-parts options and the empty profile registry.
- `vars/`: this flake's inventory, calling `makeHost`/`makeUser`. All PII and
  infra identity (names, emails, addresses, hostIds) lives here.
- This flake's instance of a feature sits in the same file: a `hosts.<h>`
  module added to `flake.nixosModules.<h>`, and its `routes.<n>`
  (`{hostname; public; dns = tailnet|cloudflare; endpoint = {ip; port};}`).
  traefik and headscale turn routes into routers and DNS records.
- `hacks/`: translations from today's lib and vars; `# hack:` marks the rest.
- `hosts/<h>/`, `home/<u>/`: plain modules for one host or user. They import
  profiles, never a single feature, so deleting a feature can't break them
  silently. Push back on requests that break this.

`flake.nix` loads `apps hacks lib modules options packages vars` with import-tree. No
relative imports except data paths: reach other files through `config.flake.*`.

## Writing a feature

```nix
# Git and forgejo-cli.
{config, ...}: let
  modules.home = {pkgs, ...}: {
    programs.git.enable = true;
    home.packages = [pkgs.forgejo-cli];
  };
in {
  # Flake Modules
  flake.modules.homeManager.git = modules.home;

  # Home Configuration Modules
  flake.homeModules.default.imports = [config.flake.modules.homeManager.git];
}
```

- Importing a feature enables it: features have no `enable` option, no gates, no `mkAfter`.
  A part inside a feature may get `<feature>.<part>.enable` only if all hold:
  it runs on its own (a gateway, a web UI), consumers disagree on it, and
  splitting it into its own feature would duplicate the shared config.
  `mkDefault` only on values consumers tune (images, packages, models).
- Features never import other features; profiles wire them. Upstream modules
  (`home-manager`, `nix-index-database`) are imported by the feature using them.
- Package lists are `pkgs-<name>` features in the domain they serve.
- Read consumer values from module-level `config.vars`. Never take a `user`
  specialArg, host identity or secrets.
- Every file opens with a one-line description.
- stateVersion is set once, in `nix/state-version.nix`.

Domains: `nix` (Nix and flake plumbing), `system` (host OS behaviour), `shell`
(the interactive terminal), `dev` (writing and running code), `ai` (agents,
models, memory), `network` (tailnet and routing).

## Style

- Fewest lines. Re-read every edit and collapse what fits on one line.
- Nix over config files; only what Nix can't express (skills) stays as files.
- Plain attrsets over functions. A mature flake or library beats hand-rolled
  code, even as a new dependency.
- Comments only where a reader would stumble. Why goes in the commit message.
- Alejandra formats. Blank lines between attrsets, never inside a list. Dotted
  keys for one value, nesting for several.

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
- `lib/`: the consumer contract only (`makeUser`, `makeHost`, `makeEnvFile`).
- A feature with options is a dir: `options.nix` declares them (and its consumer
  functions) on the same `flake.modules.<class>.<feature>`, `default.nix` sets
  config: `ai/agents/rules/options.nix` declares `agents.md` and `makeAgentRules`.
- Modules are pure config. Any computation is a named `make<Thing>` in its
  feature's `_lib/` (`network/traefik/_lib/make-traefik-http.nix`), or the
  domain's if features share it (`ai/agents/_lib`); import-tree skips
  `/_` paths, so the feature imports them itself. Packages and scripts are
  overlays in the same places' `pkgs/` (`nix/nix/pkgs/nx.nix`); features use
  `pkgs.<name>`.
- `options/`: global flake-parts options and the empty profile registry.
- `vars.nix`: the values every host and user shares (domain, tailnet, time
  zone, flake path), merged into the flake's inputs, which hosts and users pass
  as specialArgs.
- This flake's instance of a feature sits in the same file: a `hosts.<h>`
  module added to `flake.nixosModules.<h>`, the feature itself added to
  `flake.nixosModules.<h>`/`flake.homeModules.<u>` for the hosts and users
  that get it, and its `routes.<n>`
  (`{hostname; public; dns = tailnet|cloudflare; endpoint = {ip; port};}`).
  traefik and headscale turn routes into routers and DNS records.
- Hosts and users import their own `nixosModules.<h>`/`homeModules.<u>`.
- `hosts/<h>/default.nix`, `users/<u>/default.nix`: one host or user, calling
  `makeHost`/`makeUser` into `flake.hosts`/`flake.users`; their PII and infra
  identity (emails, addresses, hostIds, secrets) live there. Their plain modules
  live in `_modules/` beside them. A VM is its own host (`yggdrasil-mimir`); a
  non-NixOS one gets no `nixosConfiguration`. They import profiles, never a single
  feature, so deleting a feature can't break them silently. Push back on
  requests that break this.

`flake.nix` loads `apps hosts lib modules options users` with
import-tree, with `vars.nix` merged into its inputs. No relative imports except data paths, `_lib/` and `_modules/`: reach other files
through `config.flake.*`.

## Writing a feature

```nix
# Git and forgejo-cli.
{config, ...}: let
  modules.homeManager = {pkgs, ...}: {
    programs.git.enable = true;
    home.packages = [pkgs.forgejo-cli];
  };
in {
  # Flake Modules
  flake.modules.homeManager.git = modules.homeManager;

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
- Package lists are `pkgs-<name>` features in `<domain>/packages.nix`.
- Consumer values are module args with no default (`{tailnet, ...}:`), so a
  missing one fails evaluation. Never take a `user` arg or host identity.
- A secret is such an arg too: the path of a file holding only its value
  (`{cf-dns-api-token, ...}:`). How the file gets onto the host is the
  consumer's business, never the feature's; this flake's instance declares its
  `sops.secrets.<n>` from the `secrets.yaml` beside it (or the root `secrets`)
  and passes the path as `_module.args.<n>`. Take
  it only in the module that reads it. A secret a feature can run without goes
  in a `<feature>-<part>` module importing the base (`tailscale-auth`). Build
  env files from them (`makeEnvFile`).
- Every file opens with a one-line description.
- stateVersion is set once, in `nix/state-version.nix`.

Domains: `nix` (Nix and flake plumbing), `system` (host OS behaviour), `shell`
(the interactive terminal), `dev` (writing and running code), `ai` (agents,
models, memory), `network` (tailnet and routing), `infra` (deploying and
running fleets), `desktop` (graphical sessions and their apps).

## Style

- Fewest lines. Re-read every edit and collapse what fits on one line.
- Nix over config files; only what Nix can't express (skills) stays as files.
- Plain attrsets over functions. A mature flake or library beats hand-rolled
  code, even as a new dependency.
- Comments only where a reader would stumble. Why goes in the commit message.
- Alejandra formats. Blank lines between attrsets, never inside a list. Dotted
  keys for one value, nesting for several.

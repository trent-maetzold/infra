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

- `modules/<side>/<domain>/<feature>.nix`: one feature; never names a host or
  user. `modules/shared/` registers on both sides.
- `lib/`: the consumer contract only (`makeUser`, `makeHost`,
  `makeStateVersion`, `makeDeploymentKey`).
- A feature's own options and functions live with it: `ai/agents/rules.nix`
  declares `agents.md` and `makeAgentRules`.
- `options/`: global flake-parts options and the empty profile registry.
- `vars/`: this flake's inventory, calling `makeHost`/`makeUser`. All PII and
  infra identity (names, emails, addresses, hostIds) lives here.
- `services/<s>.nix`: opinionated; picks the host, imports the modules and
  declares the routes (`makePrivateRoute`/`makeTailnetRoute`/`makePublicRoute`)
  of one service. `modules/` features only listen on loopback and export
  `my.endpoints.<name>`.
- `hosts/<h>/`, `home/<u>/`: plain modules for one host or user. They import
  profiles, never a single feature, so deleting a feature can't break them
  silently. Push back on requests that break this.

`flake.nix` loads `apps lib modules options packages services vars` with import-tree. No
relative imports except data paths: reach other files through `config.flake.*`.

## Writing a feature

```nix
{config, ...}: let
  out = {pkgs, ...}: {
    programs.git.enable = true;
    home.packages = [pkgs.forgejo-cli];
  };
in {
  # Features
  features.home.vcs.git = out;

  # Home Manager Modules
  flake.homeModules.default.imports = [config.features.home.vcs.git];
}
```

- Importing a feature enables it: features have no `enable` option, no gates, no `mkAfter`.
  A part inside a feature may get `<feature>.<part>.enable` only if all hold:
  it runs on its own (a gateway, a web UI), consumers disagree on it, and
  splitting it into its own feature would duplicate the shared config.
  `mkDefault` only on values consumers tune (images, packages, models).
- Features never import other features; profiles wire them. Upstream modules
  (`home-manager`, `nix-index-database`) are imported by the feature using them.
- Shared package lists: `shared/packages/<name>.nix`, joined to a profile.
- Read consumer values from module-level `config.vars`. Never take a `user`
  specialArg, host identity or secrets.

## Exporting a module

```nix
{paseo, ...}: let
  # Reusable: the attrs and settings that travel with the module everywhere.
  nixosOut = _: {services.paseo.enable = true;};

  # Concrete: this flake's instance, imported as is by the host that runs it.
  hosts.paseo.imports = [nixosOut];
in {
  # Downstream: `asgard.modules.nixos.paseo`.
  flake.modules.nixos.paseo = nixosOut;

  # Downstream: `asgard.nixosModules.paseo`.
  flake.nixosModules.paseo.imports = [hosts.paseo];
}
```

- `flake.modules.<class>.<name>` is the reusable module, `<class>` being `home`,
  `nixos` or `generic` (loadable in both). `flake.homeModules.<name>` and
  `flake.nixosModules.<name>` are the concrete ones; profiles, hosts and services
  import those, so they never name a reusable module.
- `flake.modules` needs `flake-parts.flakeModules.modules` in `flake.nix`'s
  `imports` (already there). It is not loaded into this flake's own eval — the
  let binding is how we use it here, and it is why the two share one definition.
- A leaf is a deferredModule: `{}`, `{...}: {...}` and a path all work, and the
  class is enforced when a consumer imports it (`nixos` into home-manager errors;
  `generic` is the escape hatch).
- Features stay the internal registry profiles wire; `flake.modules` is what
  downstream flakes import.
- stateVersion is set once, via `makeStateVersion` in `vars/global.nix`.

Domains: home `base editor lang vcs ai containers`; NixOS `base hardware network
platform ai`. `base` is imported everywhere; `core` is a domain's leftovers.

## Style

- Fewest lines. Re-read every edit and collapse what fits on one line.
- Nix over config files; only what Nix can't express (skills) stays as files.
- Plain attrsets over functions. A mature flake or library beats hand-rolled
  code, even as a new dependency.
- Comments only where a reader would stumble. Why goes in the commit message.
- Alejandra formats. Blank lines between attrsets, never inside a list. Dotted
  keys for one value, nesting for several.

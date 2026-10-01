# Refactor design

Status: the foundation is implemented and verified; subsequent migration
milestones remain open. Use ordinary modules/options and the conventional
opt-in catalog for optional services.
Documentation target: Codeberg Pages. The workplace agent package definition
is unavailable; use a separately named launcher rather than imply that installing
a guest package on the host provides isolation. Infrastructure handoff remains
an explicitly authorized operational step.

## Contract

Export ordinary `nixosModules` and `homeManagerModules`. Import a module, then
configure it with typed NixOS/Home Manager options. Personal configuration is
module configuration, not a flake input: flake inputs select source dependencies.

Module consumption:

```nix
{
  imports = [
    asgard.nixosModules.defaults
    asgard.nixosModules.wsl
  ];

  networking.hostName = "example";
  wsl = {
    enable = true;
    defaultUser = "alice";
  };
  home-manager.users.alice = {
    imports = [asgard.homeManagerModules.defaults];
    home.username = "alice";
    programs.git.settings.user.email = "alice@example.invalid";
  };
}
```

Reuse upstream identity options rather than introduce duplicate username,
hostname, or Git email options. Asgard may close over its own dependencies when
exporting modules, so consumers need not pass Asgard's inputs through
`specialArgs`. Reserve helpers for repeated construction work that normal
module configuration does not already solve.

Primary-source precedents:

- [Home Manager's NixOS flake template](https://github.com/nix-community/home-manager/blob/master/templates/nixos/flake.nix)
  imports the exported module and supplies an ordinary configuration module.
- [NixOS-WSL's exports](https://github.com/nix-community/NixOS-WSL/blob/main/flake.nix)
  expose a module bundle with `imports`;
  [its username instructions](https://github.com/nix-community/NixOS-WSL/blob/main/docs/src/how-to/change-username.md)
  use `wsl.defaultUser`, not a parameterized module constructor.
- [flake-parts' own template](https://github.com/hercules-ci/flake-parts/blob/main/template/default/flake.nix)
  uses `mkFlake`, `systems`, `perSystem`, and `flake` for system-independent
  outputs. Prefer this over maintaining `forAllSystems` and `pkgsFor` helpers.

Additional source-backed decisions:

- [nix-index-database's module exports](https://github.com/nix-community/nix-index-database/blob/161d7c91accd93034bb3c295224d9d895a778573/flake.nix#L51-L59)
  demonstrate plain module exports and enable gates. Defaults vary by project;
  upstream-style opt-in gates suit Asgard's optional services.
- [flake-parts' published-module guidance](https://flake.parts/module-arguments.html)
  recommends defining-flake scope or specific options rather than requiring
  consumer `specialArgs`.
- [import-tree's implementation](https://github.com/vic/import-tree/blob/eb1b52eaecc57f7c136d07ae8a93e724dfecac46/default.nix)
  excludes underscore-prefixed paths but does not automatically exclude
  `default.nix`. Keep aggregators outside scanned roots or remove them.
- [ragenix's module exports](https://github.com/yaxitech/ragenix/blob/83bccfdea758241999f32869fb6b36f7ac72f1ac/flake.nix#L365-L367)
  reuse agenix's modules. Adopt its CLI/module dependency without inventing a
  second general secret registry.
- [agenix's source options](https://github.com/ryantm/agenix/blob/3daa710894355fa2fad8243380af373a2b4046ef/modules/age.nix#L178-L210)
  distinguish encrypted `file` paths and decrypted runtime `path` strings.
- [Terranix's flake-parts integration](https://terranix.org/docs/getting-started/flake-modules/)
  provides the generation interface. Its standard run application applies
  infrastructure; generation must be separate from operational approval.

## Selection

Keep base defaults separate from optional services, quadlets, and infrastructure.
Importing the base module must not unexpectedly enable every container or VM.
Register optional features with explicit enable flags, following the usual NixOS
catalog pattern. A small defaults profile enables everyday tooling with
`mkDefault`; heavyweight services remain opt-in. This supersedes the blanket
Asgard-declared-default-on policy. Use import-tree only on directories containing
modules, not on libraries, overlays, checks, or Terraform helper functions.

## Secrets

Two distinct inputs need distinct types:

- An **encrypted source file** may be a Nix path and feed `age.secrets.<name>.file`.
- A **runtime plaintext location** is a string such as an environment-file path;
  never read its contents during evaluation or turn it into a store source.

For each optional credential, an explicit absent value (`null`) is preferable to
`builtins.pathExists`: an omitted optional secret is valid; a supplied but invalid
file should not silently disable authentication.

Emit the secret declaration and the consumer attribute only when the feature is
enabled and its credential is supplied. Guard the entire attribute, not just an
interpolated fragment. Resolve `config.age.secrets.<name>.path` only inside that
branch. For multiple optional shell credentials, combine only present entries;
with none present, Asgard contributes no `home.sessionVariablesExtra` definition.

Check all combinations: disabled/present, disabled/absent, enabled/present,
enabled/absent, and multiple credentials with only one present. Tests use dummy
files and synthetic identities; no real secrets are copied into Asgard.

## Agent workflow

The consumer has used
`config.containers.hermes-agent.config.services.hermes-agent.package` in
`home.packages`. This shares a derivation, but does not establish that the host
command enters the container: that depends on what the package actually does.
NixOS containers share the host store, and Home Manager installs the referenced
derivation into the host profile. Keep the service's `package` option conventional
and expose a separately named host launcher that actually enters the guest.
Use native container-entry tooling with an explicit non-root guest user, working
directory, TTY and exit-status behavior. Host authorization grants must be narrow;
do not grant passwordless access to unrestricted `systemd-run` or `machinectl`.
Workspace and runtime credential mounts stay explicit and downstream-configured.

Sources: [Home Manager's package installation](https://github.com/nix-community/home-manager/blob/bf3f7a120d14e1bc51f4e1c3739fa6f3a98e9233/modules/home-environment.nix#L931-L935),
[NixOS container store sharing](https://github.com/NixOS/nixpkgs/blob/b4fd65b198c599cbe814fcb9f42d25d021595ec9/nixos/modules/virtualisation/nixos-containers.nix#L199-L214),
and [systemd-run's guest/PTY options](https://github.com/systemd/systemd/blob/v261.3/man/systemd-run.xml).
A real launch check is required; evaluating a launcher derivation is not proof
of its interactive or isolation behavior.

## Infrastructure

Terranix generates Terraform/OpenTofu configuration; it does not eliminate state
or the plan/apply lifecycle. OCI already has state files in Midgard. Preserve
resource addresses and provider versions until their migrations are reviewed.

The current libvirt VM configuration includes existing storage, PCI/USB
passthrough, custom QEMU arguments, and a stable domain identity. Provider support
must be checked against that actual configuration before deleting NixVirt. The
[current domain schema](https://github.com/dmacvicar/terraform-provider-libvirt/blob/main/docs/resources/domain.md)
has native block disks and host devices, but UUID is read-only and the top-level
schema does not advertise arbitrary QEMU command-line arguments. Verify the
pinned release and adoption path; do not assume that claimed XML-schema coverage
means exact parity with the existing definition.

Generation and evaluation are allowed during this refactor. Infrastructure
import, apply, destroy, VM replacement, deployment, and secret decryption are
separate operational steps requiring explicit authorization.

## Inventory and baseline

Both repositories contain existing staged, unstaged, and untracked work. Preserve
it; do not reset either repository or broadly stage unrelated files.

- Asgard: Home Manager and NixOS modules, overlays and helpers now live under
  `nix/`, with a shrinking `nix/home/config` tree.
- Midgard dependencies to move behind Asgard: Colmena, disk tooling, Quadlet
  tooling, ragenix; replace NixVirt with Terranix rather than migrate it.
- Midgard stacks: 25 Compose directories, requiring semantic conversion to
  Quadlets. Exclude Traefik; remove Dockhand. Parameterize domains, mount locations,
  identities, endpoints, and credential-file references instead of copying values.
- Host identity, hardware reports, disk layouts, networking addresses, SSH hosts,
  encrypted secrets, and Terraform state remain downstream.
- Some Midgard host imports refer to already-deleted files; their relocated files
  must be incorporated without restoring superseded copies.
- The Pi import blocker in TODO is stale: `./pi` is already imported and tracked.
- `nix flake check --all-systems --no-build` passes before the refactor, but the
  option-doc evaluations use `_module.check = false` and are not integration tests.
- A real standalone Home Manager activation evaluation initially failed because
  `home/modules/agents/default.nix` referenced the deleted `home/config/agents`
  directory. Removing that stale source fixed evaluation; the synthetic user's
  activation derivation now evaluates, and changed-file LSP diagnostics are clean.
  This is evaluation evidence, not a build or activation.

Foundation verification now covers real NixOS toplevel and Home Manager
activation derivations on x86_64-linux and aarch64-linux, using the exported
catalogs/profiles without dependency `specialArgs`. Catalog opt-in behavior,
consumer disable/leaf/list overrides, and single overlay/shared-module wiring
are checked in `nix/checks/default.nix`, including integrated Home Manager with
`useGlobalPkgs = false`. Closure-backed catalogs use source-anchored standard
module keys to deduplicate profile/shared imports. Foundation overlays use
`mkBefore` so ordinary consumer overlays win. `nix fmt` and
`nix flake check --no-build --all-systems` pass; the native module-evaluation,
option-JSON and CommonMark packages build. No system was built or activated.

The old Asgard Headscale definition contained deployment-specific values.
These now live in Midgard's `hosts/heimdall/headscale.nix`; Asgard keeps gated,
identity-free Headscale/Headplane defaults. Downstream as a whole has not yet
been repaired or verified.

## Execution order

1. Complete the migration matrix and primary-source design review; agree on the
   interface, optional-feature selection, agent workflow, and documentation host.
2. Move Nix under `nix/`, adopt flake-parts, close over upstream dependencies,
   expose modules, and replace doc-only checks with real integration checks.
3. Move reusable Midgard logic; parameterize identity and secret delivery; simplify
   downstream to Asgard imports plus host/user configuration.
4. Convert the stack catalog to Quadlets; implement bare-NixOS Traefik separately.
5. Generate Terranix configurations preserving OCI resource addresses and covering
   the existing VM requirements; document state handoff without performing it.
6. Complete agent containers, Hermes, skills/npins, MCP, language/LSP, editor, and
   plugin TODOs against verified upstream interfaces.
7. Generate and publish option documentation through CI; evaluate both architectures
   and downstream hosts/homes, test optional secrets and consumer overrides, and
   account for every TODO item before declaring completion.

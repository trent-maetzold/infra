# Asgard

Opinionated NixOS + home-manager defaults (flake-parts, dendritic: every file
under `apps/`, `lib/`, `modules/`, `options/`, `packages/`, `vars/` is
auto-imported by import-tree), plus this flake's own hosts and users.

- `modules/`: reusable features, joined into profiles
  (`nixosModules.*`, `homeModules.*`).
- `lib/`: the public functions (`flake.lib.*`, contract below).
- `vars/`: this flake's inventory, calling `makeHost`/`makeUser` with literal
  arguments; the only place routing results into `flake.*`.
- `hosts/<h>/`, `home/<u>/`: plain (non-dendritic) modules for one host or
  user, passed to the functions through `imports`. Secrets live in the private
  `secrets` flake input.

## Consuming (the contract)

Profiles are the modules; the functions only wire them to a host or user.

```nix
inputs.asgard.url = "git+https://codeberg.org/trkm/asgard";

let
  inherit (asgard.lib) makeAgentRules makeHost makeStateVersion makeUser;
  # One stateVersion and one set of values features read, shared by all.
  global = {
    imports = [(makeStateVersion "26.11")];
    vars.tailnet.loginServer = "https://hs.work.com";
  };
  trent = makeUser {
    name = "trent";
    groups = ["wheel"];               # all optional below `name`
    shell = "zsh";                    # set where a feature enabled it
    publicKey = "ssh-ed25519 ...";    # authorized key
    git = {name = "Trent"; email = "trent@work.com";};
    flake = "/home/trent/code/infra"; # nh
    hosts = {inherit box;};           # ssh client entries
    imports = [global asgard.homeModules.default ./home/trent (makeAgentRules {workflow = "- Open a PR.";})];
  };
  box = makeHost {
    name = "box";
    system = "x86_64-linux";
    imports = [global asgard.nixosModules.default asgard.nixosModules.tailnet ./hosts/box];
    users = [trent];
    specialArgs = inputs;             # optional below `name`/`system`
    address = "box.example.com";      # ssh HostName
    hostId = "deadbeef";
    lan = {address = "10.0.0.2"; prefixLength = 24; gateway = "10.0.0.1"; nameservers = []; interfaces = ["eno1"];};
    deployment = {targetHost = "10.0.0.2"; keys.x.secret = "x.age";};
  };
in {
  nixosConfigurations.box = box.nixosConfiguration;
  homeConfigurations.trent = trent.homeConfiguration "x86_64-linux";
}
```

- `makeUser` → `{name, homeModule, nixosModule, homeConfiguration = system: ...}`.
- `makeHost` → `{name, system, specialArgs, nixosModule, nixosConfiguration, ssh, colmenaNode?}`
  (`colmenaNode` with `deployment`; `lan.interfaces` bond into `bond0` behind `br0`).
- `makeStateVersion v` → a module setting `system`/`home` stateVersion; once per flake.
- `makeAgentRules {context boundaries workflow style commands tools}` → a home
  module appending to those `~/.agents/AGENTS.md` sections.
- `makeAgentSkill {name, description, text, scripts?, references?}` → a home
  module writing `~/.agents/skills/<name>/` (scripts and references map file
  names to text or paths; scripts are executable).
- `makeDeploymentKey {secret, destDir?, user?, group?}` → a colmena key.

Profiles: `nixosModules.{default,nvidia,qemu-guest,tailnet,wsl}`,
`homeModules.{default,data,infra}`. Features read `config.vars` (e.g.
`tailnet` needs `vars.tailnet.loginServer`). Override with `lib.mkForce`.
This flake's homes are `legacyPackages.<system>.homeConfigurations.<u>`.

## Commands

```sh
nix fmt                          # format (alejandra)
nix flake show                   # outputs
nix flake check                  # evaluate and run checks
colmena apply --on heimdall  # deploy (never from CI)
nix build .#options-commonmark   # every option, rendered with defaults
nix build .#options-json         # machine-readable options
```

Reviewing a rebuild diff, from a host config:

```sh
nh home build -d always   # package diff; needs nvd on PATH
nh os build -d always
nix store diff-closures /run/current-system ./result  # zero extra tools
```

## Docs

Desired policy and conventions live in AGENTS.md.

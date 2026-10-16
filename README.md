# Asgard

NixOS + home-manager defaults as importable profiles, plus this flake's own
hosts and users. Rules for editing it are in AGENTS.md.

## Use it

1. Add the input: `inputs.asgard.url = "git+https://codeberg.org/trkm/asgard";`
2. Build users and hosts with `asgard.lib`:

```nix
let
  inherit (asgard.lib) makeAgentRules makeHost makeStateVersion makeUser;
  # One stateVersion and the values features read, shared by everything.
  global = {
    imports = [(makeStateVersion "26.11")];
    vars.tailnet.loginServer = "https://hs.work.com";
  };
  trent = makeUser {
    name = "trent";
    groups = ["wheel"];               # everything below `name` is optional
    shell = "zsh";
    publicKey = "ssh-ed25519 ...";
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
    specialArgs = inputs;             # everything below here is optional
    address = "box.example.com";      # ssh HostName
    hostId = "deadbeef";
    lan = {address = "10.0.0.2"; prefixLength = 24; gateway = "10.0.0.1"; nameservers = []; interfaces = ["eno1"];};
    deployment = {targetHost = "10.0.0.2"; keys.x.secret = "/path/to/x.age";};
  };
in {
  nixosConfigurations.box = box.nixosConfiguration;
  homeConfigurations.trent = trent.homeConfiguration "x86_64-linux";
}
```

3. Override any value with `lib.mkForce`; drop a profile to drop its features.

## Profiles

- `nixosModules`: `default`, `nvidia`, `qemu-guest`, `tailnet`, `wsl`
- `homeModules`: `default`, `data`, `infra`

Features read your values from `config.vars` (`tailnet` needs
`vars.tailnet.loginServer`).

## Functions

- `makeUser` → `{name, homeModule, nixosModule, homeConfiguration = system: ...}`
- `makeHost` → `{name, system, specialArgs, nixosModule, nixosConfiguration, ssh, colmenaNode?}`;
  `colmenaNode` only with `deployment`; `lan.interfaces` bond into `bond0` behind `br0`.
- `makeStateVersion v` → module setting `system`/`home` stateVersion; once per flake.
- `makeDeploymentKey {secret, destDir?, user?, group?}` → colmena key, decrypted
  with rage from an age file on the deploying machine at apply time.
- `makeCli {name, script}` → home module installing a PEP 723 (`uv init --script`)
  script as `name`, run on a Nix Python with its dependencies (pyproject-nix).
- `makeAgentRules {context boundaries workflow style commands tools}` → home
  module adding lines to those `~/.agents/AGENTS.md` sections (`agents.md.<section>`).
- `makeAgentSkill {name, description, text, scripts?, references?}` → home
  module adding `<name>` to `~/.agents/skills` and `~/.claude/skills`; scripts and
  references map file names to text or paths, scripts are executable. Registry
  skills: set `programs.agent-skills.sources.<name>.path = <flake input>` and list
  ids in `programs.agent-skills.skills.enable` ([agent-skills-nix](https://github.com/Kyure-A/agent-skills-nix)).

## Layout

- `modules/`: features, joined into profiles; feature-owned options and
  functions sit beside them.
- `lib/`: `makeUser`, `makeHost`, `makeStateVersion`, `makeDeploymentKey`.
- `options/`: global flake-parts options and the profile registry.
- `vars/`: this flake's inventory; the only place writing hosts/users into `flake.*`.
- `hosts/<h>/`, `home/<u>/`: plain modules for one host or user.

Every `.nix` under `apps lib modules options packages vars` is loaded by
import-tree. This flake's homes are `legacyPackages.<system>.homeConfigurations.<u>`.

## Commands

```sh
nix fmt                          # format (alejandra)
nix flake check --no-build       # evaluate everything
colmena apply --on heimdall      # deploy (never from CI)
nh os build -d always            # rebuild diff; nh home build needs nvd on PATH
nix store diff-closures /run/current-system ./result
```

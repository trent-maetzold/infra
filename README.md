# Asgard

NixOS + home-manager defaults as importable profiles, plus this flake's own
hosts and users. Rules for editing it are in AGENTS.md.

## Use it

1. Add the input: `inputs.asgard.url = "git+https://codeberg.org/trkm/asgard";`
2. Build users and hosts with `asgard.lib`:

```nix
let
  inherit (asgard.lib) makeAgentRules makeHost makeUser;
  # The values features take as module args, shared by everything.
  vars = {
    tailnet.loginServer = "https://hs.work.com";
    flakePath = "/home/trent/code/infra"; # nh
    timeZone = "America/Chicago";
  };
  trent = makeUser {
    name = "trent";
    groups = ["wheel"];               # everything below `name` is optional
    shell = "zsh";
    publicKeys = ["ssh-ed25519 ..."];
    git = {name = "Trent"; email = "trent@work.com";};
    hosts = {inherit box;};           # ssh client entries
    specialArgs = vars;
    imports = [asgard.homeModules.default ./home/trent (makeAgentRules {workflow = "- Open a PR.";})];
  };
  box = makeHost {
    name = "box";
    system = "x86_64-linux";
    imports = [asgard.nixosModules.default asgard.modules.nixos.tailscale ./hosts/box];
    users = [trent];
    specialArgs = inputs // vars;     # everything below here is optional
    address = "box.example.com";      # ssh HostName
    hostId = "deadbeef";
    lan = {address = "10.0.0.2"; prefixLength = 24; gateway = "10.0.0.1"; nameservers = []; interfaces = ["eno1"];};
    deployment.targetHost = "10.0.0.2";
  };
in {
  nixosConfigurations.box = box.nixosConfiguration;
  homeConfigurations.trent = trent.homeConfiguration "x86_64-linux";
}
```

3. Override any value with `lib.mkForce`; drop a profile to drop its features.

## Profiles

- `nixosModules`: `default`
- `homeModules`: `default`, `default-slim`, `desktop`, `kids`, `infra`
- `modules.{nixos,homeManager}.<feature>`: each feature alone

Features take your values as specialArgs without defaults, so a missing one
fails evaluation (`tailscale` needs `tailnet.loginServer`, `locale` needs
`timeZone`). Secrets are the path of a file holding only the value (`traefik` needs `cf-dns-api-token`, `tailscale-auth`
needs `ts-authkey`).

## Secrets

[sops-nix](https://github.com/Mic92/sops-nix) files: a feature's own secrets
sit in `secrets.yaml` beside it; shared ones in the root `secrets.yaml`, which
modules get as the `secrets` arg (`sops.secrets.<n>.sopsFile = secrets;`).
`.sops.yaml` encrypts every `secrets.yaml` to the age master key (Bitwarden item
`age-master`) and every host's `/var/lib/age/key.txt`. `rbw unlock`, then
`sops edit <file>` (`<leader>fS` in nvim); after changing a recipient,
`sops updatekeys <file>`.

## Functions

- `makeUser` → `{name, homeModule, nixosModule, homeConfiguration = system: ...}`;
  `specialArgs` reach its home modules, standalone or on a host.
- `makeHost` → `{name, system, specialArgs, nixosModule, nixosConfiguration, ssh, colmenaNode?}`;
  `colmenaNode` only with `deployment`; `lan.interfaces` bond into `bond0` behind `br0`.
- `makeEnvFile {pkgs, name, vars}` → `{file, ExecStartPre}`: `/run/<name>.env`
  written as root before the unit starts, from `vars = {VAR = <secret file>;}`.
- `makeCli {pkgs, name, script}` → package with a PEP 723 (`uv init --script`)
  script as `bin/<name>`, run on a Nix Python with its dependencies (pyproject-nix).
- `makeAgentRules {context boundaries workflow style commands tools}` → home
  module adding lines to those `~/.agents/AGENTS.md` sections (`agents.md.<section>`).
- `makeAgentSkill {name, description, text, scripts?, references?}` → home
  module adding `<name>` to `~/.agents/skills` and `~/.claude/skills`; scripts and
  references map file names to text or paths, scripts are executable. Registry
  skills: set `programs.agent-skills.sources.<name>.path = <flake input>` and list
  ids in `programs.agent-skills.skills.enable` ([agent-skills-nix](https://github.com/Kyure-A/agent-skills-nix)).

## Layout

- `modules/<domain>/`: features, joined into profiles, with this flake's
  instance (`hosts.<h>`, `routes.<n>`) and feature-owned options beside them.
  Helpers sit in `_lib/`; packages are overlays in `pkgs/`.
- `lib/`: `makeUser`, `makeHost`, `makeEnvFile`, `makeCli`.
- `options/`: global flake-parts options and the profile registry.
- `vars.nix`: values shared by every host and user, merged into the flake's
  inputs, which they get as specialArgs.
- `hosts/<h>/default.nix`, `users/<u>/default.nix`: one host or user, calling
  `makeHost`/`makeUser` into `flake.hosts`/`flake.users`; their plain modules live
  in `_modules/`.

Every `.nix` under `apps hosts lib modules options users` (except `_` paths) is loaded by import-tree; `vars.nix` is merged into the inputs. This flake's homes are `legacyPackages.<system>.homeConfigurations.<u>`.

## Commands

```sh
nix fmt                          # format (alejandra)
nix flake check --no-build       # evaluate everything
colmena apply --on heimdall      # deploy (never from CI)
nh os build -d always            # rebuild diff; nh home build needs nvd on PATH
nix store diff-closures /run/current-system ./result
```

set shell := ["bash", "-eu", "-o", "pipefail", "-c"]

default:
    @just --list

# Wipes `target` and installs `host`; `extra` holds persist/var/lib/age/key.txt.
install host target extra:
    nix run github:nix-community/nixos-anywhere -- --flake .#{{ host }} --generate-hardware-config nixos-facter hosts/{{ host }}/_modules/facter.json --extra-files {{ extra }} --chown /persist/var/lib/age 0:0 --target-host root@{{ target }}

# A reusable tailnet key from heimdall's headscale, stored as `ts-authkey`.
ts-authkey expiration='72h':
    ssh heimdall 'sudo headscale preauthkeys create --reusable -u 1 -e {{ expiration }}' | tail -1 | nix run nixpkgs#jq -- -R . | sops set --value-stdin secrets.yaml '["tailscale"]["ts-authkey"]'

# Package diff of a host's running system against this flake.
diff host='yggdrasil':
    @if [ "$(hostname)" = {{ host }} ]; then nh os build . --hostname {{ host }} --diff always; \
    else nh os build . --hostname {{ host }} --build-host {{ host }} --target-host {{ host }} --diff always; fi

# Locks the pi.plugins extensions into pi-plugins; `update` bumps them all.
pi-plugins cmd='install':
    cd modules/ai/pi/pkgs && trap 'rm -f package.json' EXIT && nix eval --json .#pi-plugins.package > package.json && nix shell nixpkgs#nodejs -c npm {{ cmd }} --package-lock-only --legacy-peer-deps

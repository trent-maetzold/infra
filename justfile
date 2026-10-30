set shell := ["bash", "-eu", "-o", "pipefail", "-c"]

unraid_appdata := "/mnt/user/appdata"
unraid_stacks := "/mnt/user/stacks"
oci := "nix run nixpkgs#opentofu -- -chdir=terraform/oci/trkm"
oci_test := "-state=test.tfstate -var instance_name=heimdall-test -var prevent_destroy=false"

default:
    @just --list

# Copies each stack's config/ to its appdata dir, then the stacks themselves.
sync host='unraid':
    for dir in stacks/*/config; do s=$(basename "$(dirname "$dir")"); tar -C "$dir" -cf - . | ssh {{ host }} "mkdir -p {{ unraid_appdata }}/$s && tar -C {{ unraid_appdata }}/$s -xf -"; done
    rsync -av --delete stacks/ {{ host }}:{{ unraid_stacks }}/

# A throwaway heimdall on its own state file; the A1 free tier fits one.
oci-test cmd='plan' *args:
    {{ oci }}/heimdall {{ cmd }} {{ oci_test }} {{ args }}

# The network stack, then heimdall, which reads its subnet.
oci cmd='plan' *args:
    {{ oci }} {{ cmd }} {{ args }}
    {{ oci }}/heimdall {{ cmd }} {{ args }}

# heimdall first: the network it reads must outlive it.
oci-destroy *args:
    {{ oci }}/heimdall destroy -var prevent_destroy=false {{ args }}
    {{ oci }} destroy {{ args }}

oci-output *args:
    {{ oci }}/heimdall output {{ args }}

# Wipes `target` and installs `host`; `extra` holds persist/var/lib/age/key.txt.
install host target extra:
    nix run github:nix-community/nixos-anywhere -- --flake .#{{ host }} --generate-hardware-config nixos-facter hosts/{{ host }}/_modules/facter.json --extra-files {{ extra }} --chown /persist/var/lib/age 0:0 --target-host root@{{ target }}

# A reusable tailnet key from heimdall's headscale, stored as `ts-authkey`.
ts-authkey expiration='72h':
    ssh heimdall 'sudo headscale preauthkeys create --reusable -u 1 -e {{ expiration }}' | tail -1 | nix run nixpkgs#jq -- -R . | sops set --value-stdin modules/network/tailscale/secrets.yaml '["ts-authkey"]'

# Package diff of a host's running system against this flake.
diff host='yggdrasil':
    @if [ "$(hostname)" = {{ host }} ]; then nh os build . --hostname {{ host }} --diff always; \
    else nh os build . --hostname {{ host }} --build-host {{ host }} --target-host {{ host }} --diff always; fi

# Locks the pi.plugins extensions into pi-plugins; `update` bumps them all.
pi-plugins cmd='install':
    cd modules/ai/pi/pkgs && trap 'rm -f package.json' EXIT && nix eval --json .#pi-plugins.package > package.json && nix shell nixpkgs#nodejs -c npm {{ cmd }} --package-lock-only --legacy-peer-deps

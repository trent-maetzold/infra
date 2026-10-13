set shell := ["bash", "-eu", "-o", "pipefail", "-c"]

unraid_appdata_root := "/mnt/user/appdata"
unraid_stacks_root := "/mnt/user/stacks"

default:
    @just --list

sync host='unraid':
    @just sync-configs {{ host }}
    @just sync-stacks {{ host }}

sync-config service host='unraid':
    @tar -C stacks/{{ service }}/config -cf - . | ssh {{ host }} 'mkdir -p {{ unraid_appdata_root }}/{{ service }} && tar -C {{ unraid_appdata_root }}/{{ service }} -xf -'

sync-configs host='unraid':
    @for dir in stacks/*/config; do \
      [ -d "$$dir" ] || continue; \
      just sync-config "$$(basename "$$(dirname "$$dir")")" {{ host }}; \
    done

sync-stacks host='unraid':
    @ssh {{ host }} 'mkdir -p {{ unraid_stacks_root }}'
    @rsync -av --delete stacks/ {{ host }}:{{ unraid_stacks_root }}/

gen-password:
    @openssl rand -hex 24

# A throwaway instance beside the live one: its own state file, so nothing it
# plans can touch heimdall itself. It attaches to the same subnet (the network
# is read from the tenancy stack, never duplicated) and boots the same image,
# which is the point — it is how an image gets tested before the live host is
# rebuilt. At the same shape it takes the other half of the Always Free A1
# allotment, so only one of these at a time. Destroy with
# `just oci-test-apply -destroy`.
oci-test-plan *args:
    @nix run nixpkgs#opentofu -- -chdir=terraform/oci/trkm/heimdall plan -state=test.tfstate -var instance_name=heimdall-test -var prevent_destroy=false {{args}}

oci-test-apply *args:
    @nix run nixpkgs#opentofu -- -chdir=terraform/oci/trkm/heimdall apply -state=test.tfstate -var instance_name=heimdall-test -var prevent_destroy=false {{args}}

# The network is its own stack (terraform/oci/trkm) and the host stack reads
# its subnet from there, so both are walked, network first. The host stack
# builds the qcow2, uploads it and imports the image on its way to the
# instance, so a tenancy with nothing in it needs no step done by hand.
oci-plan *args:
    @nix run nixpkgs#opentofu -- -chdir=terraform/oci/trkm plan {{args}}
    @nix run nixpkgs#opentofu -- -chdir=terraform/oci/trkm/heimdall plan {{args}}

oci-apply *args:
    @nix run nixpkgs#opentofu -- -chdir=terraform/oci/trkm apply {{args}}
    @nix run nixpkgs#opentofu -- -chdir=terraform/oci/trkm/heimdall apply {{args}}

# Everything, back to nothing: the host stack first, because the network it
# reads has to outlive it. The instance's guard comes off here, which is what
# makes this the deliberate path — its disk goes with it, and the next apply
# boots a fresh one from a freshly built image.
oci-destroy *args:
    @nix run nixpkgs#opentofu -- -chdir=terraform/oci/trkm/heimdall destroy -var prevent_destroy=false {{args}}
    @nix run nixpkgs#opentofu -- -chdir=terraform/oci/trkm destroy {{args}}

oci-output *args:
    @nix run nixpkgs#opentofu -- -chdir=terraform/oci/trkm/heimdall output {{args}}

facter target='yggdrasil' host='yggdrasil-iso':
    @ssh root@{{ host }} 'nix-shell -p nixos-facter --run nixos-facter > /home/nixos/facter.json'
    @scp root@{{ host }}:/home/nixos/facter.json configurations/nixos/{{ target }}/hardware/facter.json
    @git add configurations/nixos/{{ target }}/hardware/facter.json
    @echo 'facter.json updated — review, commit, then `just install {{ target }}`'

install target='yggdrasil' host='yggdrasil-iso':
    @ssh -o BatchMode=yes -o ConnectTimeout=5 -o StrictHostKeyChecking=accept-new root@{{ host }} true
    @nix run nixpkgs#nixos-anywhere -- --flake .#{{ target }} \
        --phases kexec,disko,install \
        root@{{ host }}

# Package diff of a host's running system against this flake.
diff host='yggdrasil':
    @if [ "$(hostname)" = {{ host }} ]; then nh os build . --hostname {{ host }} --diff always; \
    else nh os build . --hostname {{ host }} --build-host {{ host }} --target-host {{ host }} --diff always; fi

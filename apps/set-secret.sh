# Usage: set-secret <name>
# Encrypts a prompted secret to the deploy key as <name>.age in the secrets
# repo ($NIX_SECRETS), on its own branch, and opens a PR.
name=${1:?usage: set-secret <name>}
repo=${NIX_SECRETS:-$HOME/code/nix-secrets}
key=${NIX_SECRETS_KEY:-$HOME/.ssh/id_ed25519.pub}

read -rsp "Secret for $name: " secret && echo
read -rsp "Confirm: " confirm && echo
[ -n "$secret" ] || { echo "empty secret" >&2; exit 1; }
[ "$secret" = "$confirm" ] || { echo "secrets differ" >&2; exit 1; }

branch=secret/$name
tree=$(mktemp -d)
trap 'git -C "$repo" worktree remove --force "$tree"' EXIT
git -C "$repo" fetch -q origin
git -C "$repo" worktree add -q -B "$branch" "$tree" origin/main

printf %s "$secret" | rage -e -R "$key" -o "$tree/$name.age"
git -C "$tree" add "$name.age"
git -C "$tree" commit -qm "secret: set $name"
git -C "$tree" push -q -u origin "$branch"
cd "$tree" && fj pr create --base main --head "$branch" --body="Sets $name.age." "secret: set $name"

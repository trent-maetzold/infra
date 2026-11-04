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

# Writes magpie's model table from the gateway.
magpie-models:
    #!/usr/bin/env python3
    import json
    import subprocess
    from itertools import groupby
    from pathlib import Path
    from urllib.request import Request, urlopen

    key = subprocess.check_output(["sops", "-d", "--extract", '["magpie"]["gateway-key"]', "secrets.yaml"], text=True).strip()
    request = Request("https://magpie.ts.trkm.io/v1/models", headers={"Authorization": f"Bearer {key}"})
    with urlopen(request, timeout=30) as response:
        models = json.load(response)["data"]
    lines = [
        "# magpie's models, as its /v1/models lists them: `id = [context window, output",
        '# limit]`, and a text-only model ends with "text", one without reasoning with',
        '# "no-reasoning". Routing groups first, then the models behind them.',
        "{",
    ]
    models = sorted((m for m in models if "/" in m["id"]), key=lambda m: m["id"])
    for index, (_, group) in enumerate(groupby(models, key=lambda m: m["id"].split("/")[0])):
        if index:
            lines.append("")
        for model in group:
            values = [model["context_window"]]
            if model["max_output_tokens"] != 131072:
                values.append(model["max_output_tokens"])
            if "image" not in model["modalities"]["input"]:
                values.append("text")
            if not model["reasoning"]:
                values.append("no-reasoning")
            lines.append(f'  {json.dumps(model["id"])} = [{" ".join(map(json.dumps, values))}];')
    lines.append("}")
    formatted = subprocess.run(["nix", "fmt", "--", "-"], input="\n".join(lines) + "\n", text=True, capture_output=True, check=True)
    Path("modules/ai/_lib/magpie-models.nix").write_text(formatted.stdout)

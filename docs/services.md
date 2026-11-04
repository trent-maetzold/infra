# Dagu, Kaneo, and Artifact Server

These are reusable NixOS features backed by quadlet-nix. Compose
`asgard.modules.nixos.dagu`, `asgard.modules.nixos.kaneo`, and
`asgard.modules.nixos.artifact-server` into your host's profile. They enable
Podman and default to loopback access. No host identity is required by a feature.

Artifact Server's image is pinned to `v0.1.2` and its digest, because the
flake-level registry auto-update needs a tag to follow. Override images through
`virtualisation.quadlet.containers.<name>.containerConfig.image`. The MCP entries
below are this flake's instance only, in `homeModules.tm`; a consumer writes
their own against their own hostname and ssh alias.

**Do the first-run steps immediately after the deploy that creates a volume.**
Until an account exists, any tailnet peer that reaches the tailnet-bound ports
can claim the admin account.

| Service | Local default | This flake on yggdrasil | State |
| --- | --- | --- | --- |
| Dagu | `http://localhost:8080` | `https://dagu.ts.trkm.io` | `dagu` volume: workflows, runs, auth |
| Kaneo | `http://localhost:5173` | `https://kan.ts.trkm.io` | `kaneo-db` volume: PostgreSQL |
| Artifact Server | `http://localhost:8788` | Loopback, reached through SSH | `artifact-server` volume: SQLite and files |

The yggdrasil instances bind Dagu and Kaneo to its tailnet IP, register the two
routes for Traefik and Headscale, and snapshot the container volumes. PostgreSQL
is on a private container network with no published port. Images can be
overridden through `virtualisation.quadlet.containers.<name>.containerConfig.image`.

For local Kaneo deployments, supply `_module.args.kaneo-db-password` and
`_module.args.kaneo-auth-secret` as paths to value-only secret files. The auth
secret must remain stable across restarts and contain at least 32 characters.
This flake supplies both through SOPS. To publish Kaneo elsewhere, override its
`publishPorts` and `environments.KANEO_CLIENT_URL` together. Dagu's bind can be
changed through its `publishPorts` as well.

## First use and MCP

- **Dagu:** visit `/setup` and create the first administrator. Create an API key
  with MCP access, then export `DAGU_API_KEY` in the session that runs the agent.
  The shared MCP entry targets `https://dagu.ts.trkm.io/mcp` with a bearer header
  holding the literal `${DAGU_API_KEY}`. Clients must expand environment
  variables in MCP headers; the header is a permanent 401 otherwise, since
  nothing else in the repo sets that variable.
- **Kaneo:** create the first account in the web UI. The shared MCP entry targets
  `https://kan.ts.trkm.io/api/mcp`; an OAuth-capable client signs in and asks for
  consent. Kaneo provides OAuth discovery at the same origin. SMTP, external
  identity providers, and S3 uploads are optional and are not configured here.
- **Artifact Server:** its MCP entry executes the built-in stdio bridge inside
  the running container through `ssh yggdrasil` and passwordless `sudo`. SSH must
  already be authenticated; this is the existing workstation-to-host trust
  relationship. The bridge reads the server's generated credential inside its
  volume, so no API key is copied into the MCP config.

To browse Artifact Server on yggdrasil, keep this tunnel open and visit
`http://localhost:8788`:

```sh
ssh -N -L 8788:127.0.0.1:8788 yggdrasil
```

For a local NixOS deployment, configure an MCP stdio command without SSH:

```sh
sudo -n podman exec -i artifact-server node dist/cli/main.js mcp --data /var/lib/artifact-server/data
```

Artifact Server deliberately runs in local-owner mode, which binds only
loopback. It uses host networking so that loopback is reachable from the host;
there is no wildcard port publication. Its `start --managed` command keeps the
service record needed by the MCP bridge. A remote HTTPS team installation is a
separate choice: upstream requires an OIDC/WorkOS provider and a wildcard content
domain on a different registrable domain from the application. Do not place the
local-owner instance behind a remote reverse proxy.

Merging the PR does not activate hosts. Deploy yggdrasil for the containers and
Heimdall for the routes/DNS, then activate the tm home configuration for the MCP
entries. Then, in the same sitting:

1. Open `https://dagu.ts.trkm.io/setup` and create the administrator, then an API
   key with MCP access.
2. Open `https://kan.ts.trkm.io` and create the first account.
3. Authorize Kaneo's MCP server once from an OAuth-capable client.

Dagu and Kaneo are bound to the tailnet address, so their direct ports are
plaintext HTTP that bypasses Traefik's TLS and tailnet middleware. That is a
known trust-boundary exception: restrict `yggdrasil:8080,5173` in the tailnet ACL
to heimdall and those who need direct access.

Neither service has an application-level backup. The volume snapshots above
protect the disk, not a bad migration; run `sudo podman exec kaneo-db pg_dump -U kaneo kaneo`
before upgrades. `tests/services-smoke.py` re-runs the container smoke test
(podman, no Nix).

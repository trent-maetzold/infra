# Migration scope

This is an execution ledger; the foundation is verified, not the whole migration.
Current working-tree files are authoritative; preserve existing changes in both repos.

## Verified foundation

Nix has moved under `nix/`; flake-parts owns system outputs, and import-tree
scans only module roots. Explicit catalogs, defaults/development profiles and
construction exports replace consumer dependency bags. Real synthetic NixOS
and Home Manager derivations evaluate on both architectures; opt-in/override
and single-overlay checks pass. Native module-check, option-JSON and CommonMark
packages build. The stale deleted agent-config reference is removed. No actual
systems were built or activated. All subsequent areas remain pending.

## Ownership

| Area | Asgard owns | Downstream retains |
| --- | --- | --- |
| Dependencies | Home Manager, WSL, LazyVim, agent packages, Colmena, disko/disko-zfs, Quadlet tooling, ragenix, flake-parts, Terranix | Asgard input and consuming lock |
| Host/home construction | Exported modules, overlays, genuinely reusable helpers | Host/user instances, state versions, hardware, disk layouts, networking, SSH destinations |
| Deployment | Pinned Colmena tool and reusable key specification | Hive nodes, targets, secret selections, file ownership, decryption identities |
| Credentials | Optional encrypted-file/runtime-path options and conditional consumers | Actual encrypted files, plaintext credentials, keys and runtime environment files |
| Containers | Sanitized application definitions under `nix/quadlets` | Storage locations, domains, endpoints, identities, enabled workloads, credential files |
| Infrastructure | Terranix modules for OCI and libvirt | Root configurations, resource names/IDs, tenancy, VM identities/devices, provider locks, state |

NixVirt is replaced, not moved. Dockhand is excluded. Traefik is implemented as a
native NixOS service, not an Asgard Quadlet. Host-local Docker-label discovery
cannot follow Traefik to another machine: downstream must supply remote backend
routes explicitly.

## Quadlet catalog

The Compose inventory contains 25 stack directories. Convert the following
retained definitions after reviewing them for embedded secrets; do not bulk-copy
the source tree:

- authelia, flaresolverr, forgejo, headscale, hermes, homeassistant, honcho, immich
- kometa, lidarr, litellm, openhands, openwebui, plex, postgres, prowlarr
- qbittorrent, radarr, recyclarr, sabnzbd, searxng, seerr, sonarr, tuwunel

Traefik is the remaining directory and is handled natively. Dockhand exists in
the old Nix Quadlet definitions, not in this stack-directory inventory.

Resolve the overlap between native Headscale and its stack without duplicating
configuration. Clarify the TODO's Pi/Hermes-only agent policy against the request
to migrate the existing OpenHands stack: retaining a selectable template need
not mean enabling or installing that agent by default.

Additional configuration needing selective sanitization includes Authelia's user
database, Forgejo's environment file, model-gateway endpoints, media API keys,
PostgreSQL initialization scripts, Recyclarr includes, and proxy authentication.
Current actual credentials and user databases stay downstream. Stack metadata
for the discarded Dockhand workflow is not required for Quadlet operation.

## Infrastructure scope

Two current OCI roots declare these nine managed resource addresses:

```text
oci_core_vcn.trkm
oci_core_internet_gateway.trkm_internet_gateway
oci_core_route_table.trkm_route_table
oci_core_security_list.trkm_security_list
oci_core_subnet.net
oci_core_instance.heimdall
oci_objectstorage_bucket.image
terraform_data.image
oci_core_image.nixos
```

Preserve addresses and separate state roots while changing the configuration
language. Nix module composition does not require Terraform module nesting.
Existing roots select different OCI provider versions (9.2.0 and 9.1.0); do not
upgrade or unify them implicitly. OCI image generation/upload orchestration also
needs review: the old relative flake path resolves to the `terraform` directory,
not the downstream flake root.

The existing libvirt definition uses block storage, PCI/USB passthrough, custom
QEMU arguments, and a stable UUID. Confirm the pinned libvirt provider can model
all of these. Do not make the existing ZFS volume a newly managed disposable
Terraform volume. Document domain import and single-manager handoff; do not
execute them during configuration refactoring.

Review existing risky behavior rather than normalize it into reusable defaults:
proxy TLS verification disabled, overly broad OCI ingress ranges, boot-volume
destruction policy, and privileged container socket/device access.

## TODO coverage

| Existing TODO | Planned disposition / verification |
| --- | --- |
| Deleted `pi.nix` import | Verified: stale Pi/agent-config references are removed and real Home Manager activation evaluates. |
| `nix/` structure + import-tree | Foundation verified: modules/home/lib/overlays moved; tree imports are scoped to module roots. Quadlet/infrastructure contents remain pending. |
| Move system helpers into flake | Verified: replaced custom helpers with flake-parts `systems`/`perSystem`. |
| flake-parts + flake-utils | Verified: flake-parts adopted; direct flake-utils omitted because it duplicates the same loop. Transitive upstream usage is unchanged. |
| ragenix | Own dependency and upstream imports here; preserve age activation decryption and downstream secret ownership. |
| Profiles/suites | Verified: explicit catalog/defaults/development selection and consumer disable tests, without a second framework. |
| Retire `home/config` | Translate LazyVim and LSP/Pi configuration into Nix. Preserve only agent-facing Markdown that is still intended. |
| agent-skills-nix + npins | Pin skill sources, use verified upstream Home Manager interface, remove hardcoded copied skill trees. |
| Pi/Hermes NixOS containers | Explicit workspace/credential mounts; verify the installed command truly launches in the container if isolation is intended. |
| Hermes module | Provide a typed opt-in module using the pinned upstream package and verified CLI behavior. |
| MCP | Shared server definitions, per-server gates, runtime credential-file references, mcp-cli entrypoint; no credentials in generated store configs. |
| Pi plugins | Review overlapping capabilities and keep the minimal set preserving intended workflows. |
| Protobuf | Language module with packaged LSP and formatter; command smoke checks. |
| Nix LSP | Verified completion/settings improvement; document project-specific nixpkgs/option expressions rather than embed downstream paths. |
| Every LSP in languages / pi-lens | Language-owned definitions feeding editor and pi-lens through verified schemas; check generated configs and executable paths. |
| Nvim `jk` | Translate and verify insert-mode mapping through LazyVim's supported config interface. |
| CI option docs / hosted site | Build option docs and site, publish on Codeberg Pages; separate repository code from required forge/runner/token setup. |

## Validation gates

1. Parse and format all changed Nix. Evaluate flake outputs on x86_64-linux and
   aarch64-linux. Do not claim cross-architecture builds if only evaluated.
2. Evaluate real NixOS and Home Manager configurations with synthetic host/user
   identities, overlays and actual upstream module imports. Doc evaluation with
   `_module.check = false` is not an integration check.
3. Test consumer overrides and opt-in service defaults. Test secret-present and
   secret-absent cases with each feature both enabled and disabled, including
   mixed provider credentials.
4. Evaluate every migrated Quadlet definition with synthetic configuration;
   check dependencies, networks, mounts, credentials and generated unit content.
5. Generate Terranix JSON, preserve resource addresses, and validate with pinned
   providers where feasible, without reading state or contacting infrastructure.
6. Evaluate downstream host/home outputs after repairing stale imports to the
   already-relocated files. Leave hardware/user facts downstream.
7. Build docs/site and check CI syntax. Record manual publishing prerequisites as
   blockers until completed; do not claim a live site from a configuration file.

No infrastructure apply/import/destroy, VM replacement, system deployment,
secret decryption, broad staging, reset, or commit is implied by these checks.

{
  config,
  lib,
  hermes-agent,
  ...
}: let
  cfg = config.services.hermes-agent;

  # ── MCP server presets ────────────────────────────────────────────────
  # Each preset is a published npx/uvx-launchable MCP server. Runtime
  # secrets are NOT baked in: env values are "\${VAR}" placeholders that
  # hermes resolves from the env files / values given to the service
  # (services.hermes-agent.environmentFiles, settings, ...). Set the real
  # secrets there — see the option description below.
  #
  # Preset   Server                        Launch style
  # -------  ----------------------------  --------------------------------
  # gmail    @gongrzhe/server-gmail-       npx (Gmail AutoAuth, OAuth
  #          autoauth-mcp                     creds in ~/.gmail-mcp)
  # protonmail proton-mail-mcp             npx (SMTP app password)
  # ynab     ynab-mcp-server               uvx (YNAB_PAT personal access
  #                                        token from https://api.ynab.com)
  # arrs     mcp-arr-server                npx (Sonarr/Radarr/Lidarr/
  #                                        Prowlarr API keys)
  # qbittorrent qbittorrent-mcp-server     npx (Web UI login)
  # plex     plex-mcp                      uvx (Plex token)
  presets = {
    gmail = {
      runner = "npx";
      pkg = "@gongrzhe/server-gmail-autoauth-mcp";
      args = [];
      envNames = [];
    };
    protonmail = {
      runner = "npx";
      pkg = "proton-mail-mcp";
      args = [];
      envNames = ["PROTONMAIL_USERNAME" "PROTONMAIL_PASSWORD"];
    };
    ynab = {
      runner = "uvx";
      pkg = "ynab-mcp-server";
      args = [];
      envNames = ["YNAB_PAT"];
    };
    arrs = {
      runner = "npx";
      pkg = "mcp-arr-server";
      args = [];
      envNames = [
        "SONARR_URL"
        "SONARR_API_KEY"
        "RADARR_URL"
        "RADARR_API_KEY"
        "LIDARR_URL"
        "LIDARR_API_KEY"
        "PROWLARR_URL"
        "PROWLARR_API_KEY"
      ];
    };
    qbittorrent = {
      runner = "npx";
      pkg = "qbittorrent-mcp-server";
      args = [];
      envNames = ["QBITTORRENT_BASE_URL" "QBITTORRENT_USERNAME" "QBITTORRENT_PASSWORD"];
    };
    plex = {
      runner = "uvx";
      pkg = "plex-mcp";
      args = ["--baseurl" "\${PLEX_BASEURL}" "--token" "\${PLEX_TOKEN}"];
      envNames = [];
    };
  };

  # env → "\${VAR}" placeholders, resolved from the service env at runtime.
  placeholderEnv = names: lib.genAttrs names (name: "\${${name}}");

  mcpPreset = name: preset: {
    command = preset.runner;
    args =
      (lib.optional (preset.runner == "npx") "-y")
      ++ [preset.pkg]
      ++ preset.args;
    env = placeholderEnv preset.envNames;
  };
in {
  imports = [
    hermes-agent.nixosModules.default
  ];

  options.services.hermes-agent.assistant.mcpServers = lib.mkOption {
    type = lib.types.attrsOf (lib.types.submodule {
      options.enable = lib.mkEnableOption "this MCP preset";
    });
    default = {};
    description = ''
      Pre-wired MCP servers for the usual self-hosted assistants. Each preset
      pins the published package and wires the env placeholders the server
      needs, so `services.hermes-agent.mcpServers` stays untouched.

      Secrets are NOT inline: env values are `"''${VAR}"` placeholders that
      hermes resolves from the service environment at runtime — provide the
      real values via `services.hermes-agent.environmentFiles` (a `.env`), or
      `services.hermes-agent.settings`, or extra systemd env.

      Presets and their env variables (`NAME = placeholder`):

      - `gmail` — Gmail AutoAuth (npx). No env; OAuth credentials live in
        `~/.gmail-mcp/gcp-oauth.keys.json` + `credentials.json` for the
        service user. Run once as that user:
        `npx @gongrzhe/server-gmail-autoauth-mcp auth`
      - `protonmail` — proton-mail-mcp (npx). `PROTONMAIL_USERNAME`,
        `PROTONMAIL_PASSWORD` (SMTP app password, not the mailbox password).
      - `ynab` — ynab-mcp-server (uvx). `YNAB_PAT` (personal access token
        from https://api.ynab.com).
      - `arrs` — mcp-arr-server (npx). `SONARR_URL`/`SONARR_API_KEY`,
        `RADARR_URL`/`RADARR_API_KEY`, `LIDARR_URL`/`LIDARR_API_KEY`,
        `PROWLARR_URL`/`PROWLARR_API_KEY`. Only configure services you run;
        the server auto-detects from which vars are set.
      - `qbittorrent` — qbittorrent-mcp-server (npx). `QBITTORRENT_BASE_URL`
        (default http://localhost:8080), `QBITTORRENT_USERNAME` (default
        admin), `QBITTORRENT_PASSWORD`.
      - `plex` — plex-mcp (uvx). `PLEX_BASEURL`, `PLEX_TOKEN` (passed as
        CLI flags).

      Not here on purpose:

      - SABnzbd — no published npx/uvx stdio server exists. hermes-webui
        (if enabled) talks to SABnzbd natively; or run the Docker image
        `ghcr.io/ltmarx/sabnzbd-mcp` and point a plain `mcpServers` entry
        with `command = "docker"` at it.
      - Home Assistant — a built-in hermes toolset, not an MCP server. Set
        `HASS_TOKEN` (long-lived token) + `HASS_URL` (default
        http://homeassistant.local:8123) and enable the toolset via
        `services.hermes-agent.settings.toolsets`.
      - SearXNG — built-in search backend. Set `SEARXNG_URL` and pin it with
        `services.hermes-agent.settings.web.search_backend = "searxng"`.
    '';
  };

  config = lib.mkIf cfg.enable {
    services.hermes-agent.addToSystemPackages = lib.mkDefault true;

    # Enabled presets land in the upstream module's mcpServers option.
    # mkDefault keeps each preset overridable downstream.
    services.hermes-agent.mcpServers = lib.mkMerge (lib.mapAttrsToList (name: preset:
      lib.mkIf (cfg.assistant.mcpServers.${name}.enable or false) {
        ${name} = lib.mkDefault (mcpPreset name preset);
      })
    presets);

    assertions = [
      {
        assertion = !cfg.container.enable;
        message = ''
          asgard: hermes-agent container mode (services.hermes-agent.container.enable = true)
          is not supported. Use the native systemd service — on a host, a microvm, or
          inside a NixOS container. The container adds a mutable apt/pip layer we don't
          want; store-path hermes is fully self-modifying via its writable HERMES_HOME.
        '';
      }
    ];
  };
}

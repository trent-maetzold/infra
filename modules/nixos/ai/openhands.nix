# OpenHands Agent Canvas with Claude Code, Codex, Pi and dsh as ACP agents,
# picked under Settings → Agent. Its agent-server comes from PyPI via uvx at start.
_: let
  endpoint = {
    host = "127.0.0.1";
    port = 8010;
  };

  nixos = {pkgs, ...}: {
    users.users.openhands = {
      isSystemUser = true;
      group = "openhands";
      home = "/var/lib/openhands";
      createHome = true;
    };

    users.groups.openhands = {};

    systemd.services.openhands = {
      wantedBy = ["multi-user.target"];
      after = ["network-online.target"];
      wants = ["network-online.target"];
      # nodejs runs the Pi preset's `npx pi-acp`.
      path = with pkgs; [bash git nodejs llm-agents.claude-agent-acp llm-agents.codex-acp llm-agents.dsh llm-agents.pi];

      serviceConfig = {
        ExecStart = "${pkgs.llm-agents.openhands-agent-canvas}/bin/agent-canvas --host ${endpoint.host} --port ${toString endpoint.port}";
        User = "openhands";
        WorkingDirectory = "/var/lib/openhands";
        Restart = "always";
      };
    };
  };
in {
  # Features
  features.nixos.ai.openhands = nixos;

  my.endpoints.openhands = endpoint;
}

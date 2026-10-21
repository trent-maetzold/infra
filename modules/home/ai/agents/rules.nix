# `agents.md`, rendered to ~/.agents/AGENTS.md, and makeAgentRules to fill it:
#   makeAgentRules {boundaries = "- **NEVER** push to main.";}
{config, ...}: let
  out = {
    config,
    lib,
    ...
  }: let
    sections = ["context" "boundaries" "workflow" "style" "commands" "tools" "coding-agents"];
    # Agent modules append their own line; sort so the section order is stable.
    ordered = name: rules:
      if name == "coding-agents"
      then lib.sort builtins.lessThan rules
      else rules;
    render = name: rules: lib.optionalString (rules != []) "## ${lib.toSentenceCase (lib.replaceStrings ["-"] [" "] name)}\n\n${lib.concatLines (ordered name rules)}";
  in {
    options.agents.md =
      lib.genAttrs sections (_:
        lib.mkOption {
          type = lib.types.listOf lib.types.lines;
          default = [];
        })
      // {
        # For agents that take AGENTS.md as text (claude-code, codex).
        text = lib.mkOption {
          type = lib.types.str;
          readOnly = true;
          default = lib.concatStringsSep "\n" (lib.filter (s: s != "") (map (s: render s config.agents.md.${s}) sections));
        };
      };

    config.home.file.".agents/AGENTS.md".text = config.agents.md.text;
  };

  # Keyed so makeAgentRules can import it again without duplicate options.
  md = {
    key = "asgard#features.home.ai.agents-md";
    imports = [out];
  };
in {
  # Features
  features.home.ai.agents-md = {
    imports = [md];

    agents.md = {
      context = ["- I over-explain. Distill my requests to the facts; answer the same way."];
      boundaries = ["- **ALWAYS** read documentation. Context7 and DeepWiki MCPs are available."];

      workflow = [
        ''
          - Read the docs even when you think you know. Verify your own memory too.
          - Suggest tools that would help but are out of scope; don't add them, or any scope, without my approval.
          - One feature or issue per branch and PR, small enough to review in one sitting.
        ''
      ];

      style = [
        ''
          - Smallest possible change, always; no pre-emptive guards, features or abstractions.
          - Idiomatic code; match surrounding code. Robust, widely used libraries over hand-rolled code; skip obscure ones.
          - Typed: type hints in Python, strict TypeScript.
          - Self-documenting code. Needing a comment may mean a clumsy solution; reconsider first.
          - Comments only where a human or agent reader would stumble; fewest words. Never narrate changes ("was X, now Y"); that's a commit message.
          - Google-style docstrings, minimal. Functions returning DataFrames list the returned columns; explain a column only if needed.
          - Finish with a docs pass: comments where needed, docstrings on every changed function.
          - Python 3.14 + uv; src/<name>/ layout, root tests/, pyproject.toml.
          - Pydantic for structured data, pydantic-settings for config, httpx2 for HTTP, Polars over pandas, pytest + ruff, FastMCP for MCP servers.
          - Export classes, not instances; construct shared objects at the use site.
          - New React projects: Vite + React + TS, Tailwind + shadcn/ui, TanStack Query/Table, Jotai, openapi-typescript + openapi-fetch + openapi-react-query, Vitest + Testing Library, ESLint + Prettier.
        ''
      ];
    };
  };

  # Home Manager Modules
  flake.homeModules = {
    default.imports = [config.features.home.ai.agents-md];
    server.imports = [config.features.home.ai.agents-md];
  };

  # Functions
  flake.lib.makeAgentRules = sections: {
    imports = [md];
    agents.md = builtins.mapAttrs (_: rule: [rule]) sections;
  };
}

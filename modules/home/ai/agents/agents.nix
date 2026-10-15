{config, ...}: let
  out = {lib, ...}: {
    agents = {
      md = {
        context = ["- I over-explain. Distill my requests to the facts; answer the same way."];
        boundaries = ["- **ALWAYS** read documentation. Context7 and DeepWiki MCPs are available."];
        workflow = [
          ''
            - Read the docs even when you think you know. Verify your own memory too.
            - Suggest tools that would help but are out of scope; don't add them, or any scope, without my approval.
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
      skills = lib.mapAttrs (name: _: ./skills + "/${name}") (builtins.readDir ./skills);
    };
  };
in {
  # Features
  features.home.ai.agents = out;

  # Home Manager Modules
  flake.homeModules.default.imports = [config.features.home.ai.agents];
}

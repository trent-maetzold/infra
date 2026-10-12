{
  # Whatever node the nixpkgs pin ships, nodejs/nodejs-slim are the v24 build.
  flake.overlays.nodejs = _final: prev: {
    nodejs = prev.nodejs_24;
    nodejs-slim = prev.nodejs-slim_24;
  };
}

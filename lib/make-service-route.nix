# A `routes.<n>` value: traefik sends `hostname` to `ip:port`; `dns` says where
# its record lives.
{
  flake.lib.makeServiceRoute = {
    hostname,
    ip,
    port,
    scheme ? "http",
    insecureSkipVerify ? false,
    public ? false,
    dns ? "tailnet",
  }: {
    inherit hostname public dns;
    endpoint = {inherit ip port scheme insecureSkipVerify;};
  };
}

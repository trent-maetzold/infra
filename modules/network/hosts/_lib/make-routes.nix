# The `routes` option from flake.hosts: the machines that serve one, by name.
{lib}: hosts: lib.mapAttrs (_: host: host.route) (lib.filterAttrs (_: host: host ? route) hosts)

# The router for every route, at the tailnet's edge.
{config, ...}: {
  my.services.traefik = {
    host = "heimdall";

    modules = [
      config.features.nixos.network.traefik
      # The dashboard's assets are relative, so it only works under /dashboard/.
      {
        services.traefik.dynamicConfigOptions.http = {
          middlewares.dashboard.redirectRegex = {
            regex = "^(https?://[^/]+)/(dashboard)?$";
            replacement = "\${1}/dashboard/";
            permanent = true;
          };

          routers.traefik.middlewares = ["dashboard"];
        };
      }
    ];

    routes.traefik = config.flake.lib.makeTailnetRoute config.my.endpoints.traefik;
  };
}

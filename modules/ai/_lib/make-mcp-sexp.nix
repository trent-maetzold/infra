# `programs.mcp` servers as autolith's native S-expression configuration.
# autolith only accepts `:environment VARNAME` references, never literal values,
# and `programs.mcp` holds values, so stdio env is not rendered.
{lib}: servers: let
  quote = value: "\"${value}\"";
  render = server:
    if server ? url
    then ''(:name ${quote server.name} :transport (:type :http :url ${quote server.url}))''
    else ''(:name ${quote server.name} :transport (:type :stdio :command ${quote server.command}${
        lib.optionalString (server.args != []) " :arguments (${lib.concatMapStringsSep " " quote server.args})"
      }))'';
in ''
  (:version 1
   :servers
   (${lib.concatMapStringsSep " " render (import ./make-mcp-servers.nix {inherit lib;} servers)}))
''

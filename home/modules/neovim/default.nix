{
  config,
  lib,
  pkgs,
  ...
}: {
  config = lib.mkMerge [
    {programs.lazyvim.enable = lib.mkDefault true;}
    (lib.mkIf config.programs.lazyvim.enable {
      programs.lazyvim = {
        installCoreDependencies = lib.mkDefault true;
        configFiles = lib.mkDefault ../../config/nvim;
        # NOTE: mkDefault must sit on each leaf, never on a whole attrset:
        # a whole-value def loses against nested-path defs from other modules
        # (the languages/* modules define extras.lang.*.enable), so everything
        # else in it silently falls back to the option default.
        extras = {
          coding = {
            yanky.enable = lib.mkDefault true;
            blink.enable = lib.mkDefault true;
            mini-comment.enable = lib.mkDefault true;
            mini-snippets.enable = lib.mkDefault true;
            mini-surround.enable = lib.mkDefault true;
          };
          dap = {
            core.enable = lib.mkDefault true;
            nlua.enable = lib.mkDefault true;
          };
          editor = {
            inc-rename.enable = lib.mkDefault true;
            aerial.enable = lib.mkDefault true;
            harpoon2.enable = lib.mkDefault true;
            illuminate.enable = lib.mkDefault true;
            mini-files.enable = lib.mkDefault true;
            overseer.enable = lib.mkDefault true;
            refactoring.enable = lib.mkDefault true;
          };
          test.core.enable = lib.mkDefault true;
          ui = {
            smear-cursor.enable = lib.mkDefault true;
            treesitter-context.enable = lib.mkDefault true;
          };
          util = {
            dot.enable = lib.mkDefault true;
            mini-hipatterns.enable = lib.mkDefault true;
          };
          formatting.prettier.enable = lib.mkDefault true;
          linting.eslint.enable = lib.mkDefault true;
        };
        extraPackages = with pkgs; [
          ghostscript
          tectonic

          imagemagick
          mermaid-cli

          file
          sqlite
          trash-cli
          tree-sitter
          lua51Packages.lua
          lua51Packages.luarocks
        ];
        treesitterParsers = with pkgs.vimPlugins.nvim-treesitter-parsers; [
          css
          scss
          latex
          svelte
          typst
          vue
        ];
      };
      xdg.configFile."nvim/lua/config/nixpaths.lua".text = lib.mkDefault ''
        return {
          sqlite3_lib = "${pkgs.sqlite.out}/lib/libsqlite3.so",
        }
      '';
    })
  ];
}

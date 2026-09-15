{
  config,
  lib,
  pkgs,
  ...
}: {
  config = lib.mkMerge [
    {programs.lazyvim.enable = lib.mkDefault true;}
    (lib.mkIf config.programs.lazyvim.enable {
      programs.lazyvim = lib.mkDefault {
        installCoreDependencies = true;
        configFiles = lib.mkDefault ../config/nvim;
        extras = {
          coding = {
            yanky.enable = true;
            blink.enable = true;
            mini-comment.enable = true;
            mini-snippets.enable = true;
            mini-surround.enable = true;
          };
          dap = {
            core.enable = true;
            nlua.enable = true;
          };
          editor = {
            inc-rename.enable = true;
            aerial.enable = true;
            harpoon2.enable = true;
            illuminate.enable = true;
            mini-files.enable = true;
            overseer.enable = true;
            refactoring.enable = true;
          };
          test.core.enable = true;
          ui = {
            smear-cursor.enable = true;
            treesitter-context.enable = true;
          };
          util = {
            dot.enable = true;
            mini-hipatterns.enable = true;
          };
          formatting.prettier.enable = true;
          linting.eslint.enable = true;

          lang = lib.genAttrs [
            "docker"
            "git"
            "go"
            "json"
            "markdown"
            "nix"
            "python"
            "rust"
            "sql"
            "toml"
            "typescript"
            "yaml"
          ] (name: {enable = true;});
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

{
  config,
  inputs,
  ...
}: {
  flake.homeModules.neovim = {
    config,
    lib,
    pkgs,
    ...
  }: let
    cfg = config.programs.lazyvim;
  in {
    imports = [inputs.lazyvim.homeManagerModules.default];

    config = lib.mkMerge [
      {programs.lazyvim.enable = lib.mkDefault true;}
      (lib.mkIf cfg.enable {
        programs.lazyvim = {
          configFiles = lib.mkDefault ./config;
          extraPackages = lib.mkAfter (with pkgs; [
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
            llm-agents.copilot-language-server
          ]);
          extras = {
            ai = {
              copilot-native.enable = true;
              sidekick.enable = true;
            };
            coding = {
              blink.enable = lib.mkDefault true;
              mini-comment.enable = lib.mkDefault true;
              mini-snippets.enable = lib.mkDefault true;
              mini-surround.enable = lib.mkDefault true;
              yanky.enable = lib.mkDefault true;
            };
            dap = {
              core.enable = lib.mkDefault true;
              nlua.enable = lib.mkDefault true;
            };
            editor = {
              aerial.enable = lib.mkDefault true;
              harpoon2.enable = lib.mkDefault true;
              illuminate.enable = lib.mkDefault true;
              inc-rename.enable = lib.mkDefault true;
              mini-files.enable = lib.mkDefault true;
              overseer.enable = lib.mkDefault true;
              refactoring.enable = lib.mkDefault true;
            };
            formatting.prettier.enable = lib.mkDefault true;
            linting.eslint.enable = lib.mkDefault true;
            test.core.enable = lib.mkDefault true;
            ui = {
              smear-cursor.enable = lib.mkDefault true;
              treesitter-context.enable = lib.mkDefault true;
            };
            util = {
              dot.enable = lib.mkDefault true;
              mini-hipatterns.enable = lib.mkDefault true;
            };
          };
          installCoreDependencies = lib.mkDefault true;
          treesitterParsers = lib.mkAfter (with pkgs.vimPlugins.nvim-treesitter-parsers; [
            css
            scss
            latex
            svelte
            typst
            vue
          ]);
        };
        xdg.configFile."nvim/lua/config/nixpaths.lua".text = lib.mkDefault ''
          return {
            sqlite3_lib = "${pkgs.sqlite.out}/lib/libsqlite3.so",
          }
        '';
      })
    ];
  };
  flake.homeModules.default.imports = [config.flake.homeModules.neovim];
}

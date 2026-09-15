-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

-- jk escape: insert mode everywhere
vim.keymap.set("i", "jk", "<Esc>", { desc = "jk escape" })
-- terminal mode: jk → normal mode
vim.keymap.set("t", "jk", "<C-\\><C-n>", { desc = "jk escape (terminal)" })

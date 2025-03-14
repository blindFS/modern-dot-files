-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

vim.diagnostic.config({ virtual_text = false })
-- https://github.com/Saghen/blink.cmp/issues/1303
vim.g.lazyvim_picker = "telescope"

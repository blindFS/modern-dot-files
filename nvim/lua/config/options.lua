-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

vim.api.nvim_create_autocmd("FileType", {
  pattern = "nu",
  callback = function(event)
    vim.bo[event.buf].commentstring = "# %s"
  end,
})

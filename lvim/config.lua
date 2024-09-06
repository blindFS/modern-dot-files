-- Read the docs: https://www.lunarvim.org/docs/configuration
-- Example configs: https://github.com/LunarVim/starter.lvim
-- Video Tutorials: https://www.youtube.com/watch?v=sFA9kX-Ud_c&list=PLhoH5vyxr6QqGu0i7tt_XoVK9v-KvZ3m6
-- Forum: https://www.reddit.com/r/lunarvim/
-- Discord: https://discord.com/invite/Xb9B4Ny

lvim.plugins = {
  {"mrjones2014/nvim-ts-rainbow",
    config = function()
      require'nvim-treesitter.configs'.setup{
        rainbow = {
          -- Setting colors
          colors = {
            '#e0af68',
            '#bb9af7',
            '#7dcfff',
            '#f7768e',
            '#0dcf6f',
          },
        },
      }
    end
  },
  {
    "kylechui/nvim-surround",
    version = "*",
    event = "VeryLazy",
    config = function()
      require("nvim-surround").setup({
      })
    end
  }
}
lvim.transparent_window = true
lvim.builtin.treesitter.rainbow.enable = true

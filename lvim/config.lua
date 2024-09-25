-- Read the docs: https://www.lunarvim.org/docs/configuration
-- Example configs: https://github.com/LunarVim/starter.lvim
-- Video Tutorials: https://www.youtube.com/watch?v=sFA9kX-Ud_c&list=PLhoH5vyxr6QqGu0i7tt_XoVK9v-KvZ3m6
-- Forum: https://www.reddit.com/r/lunarvim/
-- Discord: https://discord.com/invite/Xb9B4Ny

lvim.plugins = {
  {
    "nvim-treesitter/nvim-treesitter",
    dependencies = {
      -- NOTE: additional parser
      { "nushell/tree-sitter-nu", build = ":TSUpdate nu" },
    },
    build = ":TSUpdate",
  },
  {
    "mrjones2014/nvim-ts-rainbow",
    config = function()
      require 'nvim-treesitter.configs'.setup {
        playground = {
          disable = {},
          enable = true,
          keybindings = {
            focus_language = "f",
            goto_node = "<cr>",
            show_help = "?",
            toggle_anonymous_nodes = "a",
            toggle_hl_groups = "i",
            toggle_injected_languages = "t",
            toggle_language_display = "I",
            toggle_query_editor = "o",
            unfocus_language = "F",
            update = "R"
          },
          persist_queries = false,
          updatetime = 25
        },
        incremental_selection = {
          disable = {},
          enable = true,
          keymaps = {
            init_selection = "+",
            node_decremental = "-",
            node_incremental = "+",
            scope_incremental = "g+"
          }
        },
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
  },
}
lvim.transparent_window = true
lvim.builtin.treesitter.rainbow.enable = true
lvim.keys.insert_mode["<A-j>"] = false
lvim.keys.insert_mode["<A-k>"] = false
lvim.keys.normal_mode["<A-j>"] = false
lvim.keys.normal_mode["<A-k>"] = false
lvim.keys.visual_block_mode["<A-j>"] = false
lvim.keys.visual_block_mode["<A-k>"] = false
lvim.keys.visual_block_mode["J"] = false
lvim.keys.visual_block_mode["K"] = false

vim.opt.foldmethod = "expr" -- default is "normal"
vim.opt.foldexpr = "nvim_treesitter#foldexpr()" -- default is ""
vim.opt.foldenable = false -- if this option is true and fold method option is other than normal, every time a document is opened everything will be folded.

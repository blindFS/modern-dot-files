return {
  -- eyecandy
  {
    "folke/tokyonight.nvim",
    opts = {
      transparent = true,
      styles = {
        sidebars = "transparent",
        floats = "transparent",
      },
    },
  },
  {
    "HiPhish/rainbow-delimiters.nvim",
    event = "VeryLazy",
  },
  {
    "norcalli/nvim-colorizer.lua",
    event = "VeryLazy",
    config = function()
      require("colorizer").setup()
    end,
  },
  {
    "nvim-lualine/lualine.nvim",
    opts = {
      options = {
        component_separators = { left = "", right = "" },
        section_separators = { left = "", right = "" },
      },
    },
  },
  -- keymaps
  {
    "echasnovski/mini.surround",
    event = "VeryLazy",
    opts = {
      mappings = {
        add = "'a",
        delete = "'d",
        find = "'f",
        find_left = "'F",
        highlight = "'h",
        replace = "'c",
        update_n_lines = "'n",
      },
    },
  },
  {
    "nvim-treesitter/nvim-treesitter",
    opts = {
      incremental_selection = {
        disable = {},
        enable = true,
        keymaps = {
          init_selection = "+",
          node_decremental = "-",
          node_incremental = "+",
          scope_incremental = "g+",
        },
      },
    },
    dependencies = {
      -- NOTE: additional parser
      { "nushell/tree-sitter-nu", build = ":TSUpdate nu" },
    },
  },
  {
    "nvim-telescope/telescope.nvim",
    opts = function()
      local actions = require("telescope.actions")
      return {
        defaults = {
          mappings = {
            i = {
              ["<esc>"] = actions.close,
            },
          },
        },
      }
    end,
  },
  -- nushell setup
  {
    "neovim/nvim-lspconfig",
    opts = function()
      local lspconfig = require("lspconfig")
      lspconfig.nixd.setup({
        cmd = { "nixd" },
        filetypes = { "nix" },
        settings = {
          nixd = {
            formatting = {
              command = { "nixfmt" },
            },
          },
        },
      })
      lspconfig.nushell.setup({
        cmd = {
          "/Users/farseerhe/Workspace/nushell/target/release/nu",
          -- "nu",
          "--include-path",
          vim.fn.expand("%:p:h"),
          "--no-config-file",
          "--lsp",
        },
        filetypes = { "nu" },
        offset_encoding = "utf-16",
        capabilities = {
          offset_encoding = { "utf-16" },
        },
      })
    end,
  },
  -- llm
  {
    "monkoose/neocodeium",
    event = "VeryLazy",
    config = function()
      local neocodeium = require("neocodeium")
      neocodeium.setup()
      vim.keymap.set("i", "<C-e>", neocodeium.accept)
      vim.keymap.set("i", "<C-t>", neocodeium.chat)
    end,
  },
  {
    "yetone/avante.nvim",
    event = "VeryLazy",
    lazy = false,
    version = false, -- set this if you want to always pull the latest change
    opts = {
      provider = "gemini",
      -- provider = "claude",
      gemini = {
        -- @see https://ai.google.dev/gemini-api/docs/models/gemini
        model = "gemini-1.5-pro-002",
        -- model = "gemini-1.5-flash",
        temperature = 0,
        max_tokens = 4096,
      },
    },
    -- if you want to build from source then do `make BUILD_FROM_SOURCE=true`
    build = "make",
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
      "stevearc/dressing.nvim",
      "nvim-lua/plenary.nvim",
      "MunifTanjim/nui.nvim",
      --- The below dependencies are optional,
      "nvim-tree/nvim-web-devicons", -- or echasnovski/mini.icons
      {
        -- support for image pasting
        "HakonHarnes/img-clip.nvim",
        event = "VeryLazy",
        opts = {
          -- recommended settings
          default = {
            embed_image_as_base64 = false,
            prompt_for_file_name = false,
            drag_and_drop = {
              insert_mode = true,
            },
            -- required for Windows users
            use_absolute_path = true,
          },
        },
      },
      {
        -- Make sure to set this up properly if you have lazy=true
        "MeanderingProgrammer/render-markdown.nvim",
        opts = {
          file_types = { "markdown", "Avante" },
        },
        ft = { "markdown", "Avante" },
      },
    },
  },
}

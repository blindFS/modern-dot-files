local rainbow_highlight = {
  "SnacksIndent1",
  "SnacksIndent2",
  "SnacksIndent3",
  "SnacksIndent4",
  "SnacksIndent5",
  "SnacksIndent6",
  "SnacksIndent7",
}
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
    config = function()
      require("rainbow-delimiters.setup").setup({
        highlight = rainbow_highlight,
      })
    end,
  },
  {
    "folke/snacks.nvim",
    opts = {
      indent = {
        indent = {
          priority = 1,
          enabled = true, -- enable indent guides
          char = "│",
          only_scope = false, -- only show indent guides of the scope
          only_current = true, -- only show indent guides in the current window
          hl = "SnacksIndent", ---@type string|string[] hl groups for indent guides
        },
        ---@class snacks.indent.Scope.Config: snacks.scope.Config
        scope = {
          enabled = true, -- enable highlighting the current scope
          priority = 200,
          char = "│",
          underline = true, -- underline the start of the scope
          only_current = true, -- only show scope in the current window
          -- hl = "SnacksIndentScope", ---@type string|string[] hl group for scopes
          hl = rainbow_highlight,
        },
      },
    },
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
      textobjects = {
        swap = {
          enable = true,
          swap_next = {
            ["<leader>pa"] = "@parameter.inner",
          },
          swap_previous = {
            ["<leader>pA"] = "@parameter.inner",
          },
        },
      },
    },
    config = function(_, opts)
      -- local parser_config = require("nvim-treesitter.parsers").get_parser_configs()
      -- parser_config.nu = {
      --   install_info = {
      --     url = "~/Workspace/tree-sitter-nu", -- local path or git repo
      --     files = { "src/parser.c", "src/scanner.c" }, -- note that some parsers also require src/scanner.c or src/scanner.cc
      --     branch = "pr", -- default branch in case of git repo if different from master
      --     generate_requires_npm = false, -- if stand-alone parser without npm dependencies
      --     requires_generate_from_grammar = false, -- if folder contains pre-generated src/parser.c
      --   },
      --   filetype = "nu", -- if filetype does not match the parser name
      -- }
      require("nvim-treesitter.configs").setup(opts)
      vim.treesitter.language.register("nu", "nushell")
      vim.api.nvim_create_autocmd("FileType", {
        pattern = "nu",
        callback = function(event)
          vim.bo[event.buf].commentstring = "# %s"
          vim.api.nvim_buf_set_keymap(event.buf, "i", "<C-f>", "", {
            callback = function()
              vim.lsp.buf.signature_help()
            end,
          })
          vim.api.nvim_create_autocmd("User", {
            pattern = "BlinkCmpAccept",
            callback = function(ev)
              local item = ev.data.item
              -- function/method kind
              if item.kind == 3 or item.kind == 2 then
                vim.defer_fn(function()
                  vim.lsp.buf.signature_help()
                end, 500)
              end
            end,
          })
        end,
      })
    end,
    dependencies = {
      -- NOTE: additional parser
      -- { "nushell/tree-sitter-nu" },
    },
  },
  {
    "saghen/blink.cmp",
    opts = {
      completion = {
        accept = {
          auto_brackets = {
            enabled = true,
            kind_resolution = {
              enabled = true,
              blocked_filetypes = { "nu" },
            },
            semantic_token_resolution = {
              enabled = true,
              blocked_filetypes = { "nu" },
              timeout_ms = 500,
            },
          },
        },
      },
    },
  },
  {
    "neovim/nvim-lspconfig",
    opts = function()
      local lspconfig = require("lspconfig")
      local get_flake_cmd = string.format('(builtins.getFlake "%s/nix")', vim.env.HOME)
      local flake_os_cmd = string.format("%s.darwinConfigurations.%s.options", get_flake_cmd, vim.loop.os_gethostname())
      local flake_hm_cmd = string.format("%s.homeConfigurations.%s.options", get_flake_cmd, vim.env.USER)
      lspconfig.nixd.setup({
        cmd = { "nixd" },
        filetypes = { "nix" },
        settings = {
          nixd = {
            formatting = {
              command = { "nixfmt" },
            },
            options = {
              nixos = {
                expr = flake_os_cmd,
              },
              home_manager = {
                expr = flake_hm_cmd,
              },
            },
          },
        },
      })
      lspconfig.nushell.setup({
        cmd = {
          "/Users/farseerhe/Workspace/nushell/target/debug/nu",
          -- "nu",
          "--config",
          vim.env.XDG_CONFIG_HOME .. "/nushell/lsp.nu",
          "--lsp",
        },
        flags = { debounce_text_changes = 1000 },
        filetypes = { "nu" },
      })
    end,
  },
  {
    {
      "stevearc/conform.nvim",
      dependencies = { "mason.nvim" },
      event = "VeryLazy",
      opts = {
        formatters_by_ft = {
          nu = { "topiary_nu" },
        },
        formatters = {
          topiary_nu = {
            command = "topiary",
            args = { "format", "--language", "nu" },
          },
        },
      },
    },
  },
  -- llm
  {
    "monkoose/neocodeium",
    event = "VeryLazy",
    config = function()
      local neocodeium = require("neocodeium")
      neocodeium.setup()
      vim.keymap.set("i", "<C-l>", neocodeium.accept)
      vim.keymap.set("i", "<C-t>", neocodeium.chat)
    end,
  },
  {
    "yetone/avante.nvim",
    event = "VeryLazy",
    version = false, -- set this if you want to always pull the latest change
    opts = {
      provider = "gemini",
      -- provider = "openrouter",
      behaviour = {
        enable_cursor_planning_mode = true,
      },
      gemini = {
        -- @see https://ai.google.dev/gemini-api/docs/models/gemini
        model = "gemini-2.0-flash-001",
        temperature = 0,
        max_tokens = 4096,
      },
      vendors = {
        openrouter = {
          __inherited_from = "openai",
          api_key_name = "OPENROUTER_API_KEY",
          endpoint = "https://openrouter.ai/api/v1/",
          model = "deepseek/deepseek-r1:free",
        },
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

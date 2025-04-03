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
    "neovim/nvim-lspconfig",
    opts = function(_, opts)
      -- use virtual_lines instead of virtual_text
      opts.diagnostics.virtual_text = false
      local lspconfig = require("lspconfig")
      local get_flake_cmd = string.format('(builtins.getFlake "%s/nix")', vim.env.HOME)
      local flake_os_cmd = string.format("%s.darwinConfigurations.%s.options", get_flake_cmd, vim.fn.hostname())
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
      return opts
    end,
  },
  {
    "mrcjkb/rustaceanvim",
    ft = { "rust" },
    config = function(_, opts)
      if LazyVim.has("mason.nvim") then
        local package_path = require("mason-registry").get_package("codelldb"):get_install_path()
        local codelldb = package_path .. "/extension/adapter/codelldb"
        local library_path = package_path .. "/extension/lldb/lib/liblldb.dylib"
        opts.dap = {
          adapter = require("rustaceanvim.config").get_codelldb_adapter(codelldb, library_path),
        }
      end
      -- diable checkOnSave by default
      opts.server.default_settings["rust-analyzer"].checkOnSave = false
      vim.g.rustaceanvim = vim.tbl_deep_extend("keep", vim.g.rustaceanvim or {}, opts or {})

      local function clippy()
        vim.cmd.RustLsp("flyCheck")
      end
      vim.keymap.set("n", "<leader>tc", clippy, { desc = "Run linter clippy" })
    end,
  },
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
    "olimorris/codecompanion.nvim",
    event = "VeryLazy",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-treesitter/nvim-treesitter",
    },
    opts = {
      strategies = {
        -- Change the default chat adapter
        chat = {
          adapter = "gemini",
        },
        inline = {
          adapter = "gemini",
        },
      },
    },
  },
}

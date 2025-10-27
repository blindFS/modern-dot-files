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
    config = function()
      require("rainbow-delimiters.setup").setup({
        highlight = rainbow_highlight,
      })
    end,
  },
  {
    "folke/snacks.nvim",
    opts = {
      image = { enabled = true },
      scroll = { enabled = false },
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
    config = function(_, opts)
      -- new toggle for gitsigns inline blame
      local toggle_inline_blame = {
        name = "Inline Git Blame",
        get = function()
          return require("gitsigns.config").config.current_line_blame
        end,
        set = function(state)
          require("gitsigns").toggle_current_line_blame(state)
        end,
      }
      Snacks.toggle.new(toggle_inline_blame):map("<leader>uB")

      -- new toggle for gitsigns inline blame
      vim.api.nvim_create_augroup("DiagHover", { clear = true })
      local group_opts = { group = "DiagHover" }
      local toggle_diagnostic_float_on_hover = {
        name = "Show Line Diagnostics on Hover",
        get = function()
          return #vim.api.nvim_get_autocmds(group_opts) > 0
        end,
        set = function(state)
          if state then
            vim.api.nvim_create_autocmd("CursorHold", {
              group = "DiagHover",
              pattern = "*",
              callback = function()
                vim.diagnostic.open_float()
              end,
            })
          else
            vim.api.nvim_clear_autocmds(group_opts)
          end
        end,
      }
      Snacks.toggle.new(toggle_diagnostic_float_on_hover):map("<leader>uH")

      require("snacks").setup(opts)
    end,
  },
  {
    "norcalli/nvim-colorizer.lua",
    event = "VeryLazy",
    config = function()
      require("colorizer").setup()
    end,
  },
  {
    "nvim-mini/mini.icons",
    verion = "*",
    opts = {
      filetype = {
        nu = { glyph = "", hl = "MiniIconsGreen" },
      },
    },
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
  {
    "folke/noice.nvim",
    event = "VeryLazy",
    opts = {
      lsp = {
        hover = { enabled = true },
        signature = { enabled = true },
      },
      presets = {
        lsp_doc_border = true, -- add a border to hover docs and signature help
      },
    },
  },
  {
    "MeanderingProgrammer/render-markdown.nvim",
    ft = { "markdown", "norg", "rmd", "org", "codecompanion" },
    opts = {
      heading = {
        sign = true,
        icons = { "󰲡 ", "󰲣 ", "󰲥 ", "󰲧 ", "󰲩 ", "󰲫 " },
      },
      checkbox = { enabled = true },
      completions = {
        blink = { enabled = true },
        lsp = { enabled = true },
      },
    },
  },
  {
    "saghen/blink.cmp",
    dependencies = { "archie-judd/blink-cmp-words" },
    opts = {
      completion = {
        menu = {
          draw = {
            treesitter = { "lsp" },
          },
        },
        documentation = {
          auto_show = true,
          auto_show_delay_ms = 200,
          treesitter_highlighting = true,
        },
        ghost_text = { enabled = true },
      },
      -- Optionally add 'dictionary', or 'thesaurus' to default sources
      sources = {
        default = { "lsp", "path", "snippets", "buffer" },
        providers = {

          -- Use the thesaurus source
          thesaurus = {
            name = "blink-cmp-words",
            module = "blink-cmp-words.thesaurus",
            -- All available options
            opts = {
              -- A score offset applied to returned items.
              -- By default the highest score is 0 (item 1 has a score of -1, item 2 of -2 etc..).
              score_offset = 0,

              -- Default pointers define the lexical relations listed under each definition,
              -- see Pointer Symbols below.
              -- Default is as below ("antonyms", "similar to" and "also see").
              pointer_symbols = { "!", "&", "^" },
            },
          },

          -- Use the dictionary source
          dictionary = {
            name = "blink-cmp-words",
            module = "blink-cmp-words.dictionary",
            -- All available options
            opts = {
              -- The number of characters required to trigger completion.
              -- Set this higher if completion is slow, 3 is default.
              dictionary_search_threshold = 3,
              score_offset = 0,
              pointer_symbols = { "!", "&", "^" },
            },
          },
        },

        -- Setup completion by filetype
        per_filetype = {
          text = { "dictionary" },
          markdown = { "thesaurus" },
        },
      },
    },
  },
  -- keymaps
  {
    "nvim-mini/mini.surround",
    event = "VeryLazy",
    verion = "*",
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
    branch = "main",
    opts = {
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
      vim.api.nvim_create_autocmd("User", {
        pattern = "TSUpdate",
        callback = function()
          ---@type table<string, any>
          local parser_config = require("nvim-treesitter.parsers")
          -- parser_config.nu = {
          --   install_info = {
          --     path = "~/Workspace/tree-sitter-nu", -- local path or git repo
          --     files = { "src/parser.c", "src/scanner.c" }, -- note that some parsers also require src/scanner.c or src/scanner.cc
          --     branch = "main", -- default branch in case of git repo if different from master
          --     generate_requires_npm = false, -- if stand-alone parser without npm dependencies
          --     requires_generate_from_grammar = false, -- if folder contains pre-generated src/parser.c
          --   },
          -- }

          parser_config.openscad = {
            install_info = {
              url = "https://github.com/openscad/tree-sitter-openscad",
              branch = "main",
              queries = "queries",
            },
          }
        end,
      })

      vim.api.nvim_create_autocmd("FileType", {
        pattern = "nu",
        callback = function(event)
          vim.treesitter.start()
          -- tree-sitter based folding
          vim.wo.foldexpr = "v:lua.vim.treesitter.foldexpr()"
          -- signature help keybinding
          vim.api.nvim_buf_set_keymap(event.buf, "i", "<C-f>", "", {
            callback = function()
              vim.lsp.buf.signature_help()
            end,
          })
          -- signature help after completing a command name
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

      vim.filetype.add({ extension = { openscad = "openscad" } })
      vim.api.nvim_create_autocmd("FileType", {
        pattern = "openscad",
        callback = function(event)
          vim.bo[event.buf].commentstring = "// %s"
          vim.treesitter.start()
        end,
      })

      require("nvim-treesitter").setup(opts)
    end,
  },
  {
    "neovim/nvim-lspconfig",
    opts = function(_, opts)
      -- use virtual_lines instead of virtual_text
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
          "nu",
          -- "/Users/farseerhe/Workspace/nushell/target/debug/nu",
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
    "rachartier/tiny-inline-diagnostic.nvim",
    event = "VeryLazy",
    priority = 1000, -- needs to be loaded in first
    config = function()
      require("tiny-inline-diagnostic").setup()
      vim.diagnostic.config({ virtual_text = false })
    end,
  },
  {
    "stevearc/conform.nvim",
    dependencies = { "mason.nvim" },
    event = "VeryLazy",
    opts = {
      formatters_by_ft = {
        nu = { "topiary_nu" },
        openscad = { "topiary_scad" },
      },
      formatters = {
        topiary_nu = {
          command = "topiary",
          args = { "-M", "-C", vim.env.XDG_CONFIG_HOME .. "/topiary/languages.ncl", "format", "--language", "nu" },
        },
        topiary_scad = {
          command = "topiary",
          args = { "format", "--language", "openscad" },
        },
      },
    },
  },
  {
    "nvim-mini/mini.align",
    version = false,
    config = function()
      require("mini.align").setup({
        mappings = {
          start = "al",
          start_with_preview = "aL",
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
      neocodeium.setup({ debounce = true, show_label = false })
      vim.keymap.set("i", "<C-l>", neocodeium.accept)
      vim.keymap.set("i", "<C-t>", neocodeium.chat)
    end,
  },
  -- git
  {
    "lewis6991/gitsigns.nvim",
    event = "LazyFile",
    opts = {
      -- requires the gh cli tool to show clickable links
      gh = true,
    },
    keys = {
      { "<leader>gB", "<cmd>Gitsigns blame_line<cr>", desc = "Git blame links" },
    },
  },
}

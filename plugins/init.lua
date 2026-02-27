return {

  {
    "NoahTheDuke/vim-just",
    ft = { "just", "justfile" },
  },
  {
    "stevearc/conform.nvim",
    event = "BufWritePre",
    opts = require "configs.conform",
  },
  {
    "williamboman/mason.nvim",
    opts = {
      ensure_installed = {
        "codelldb",
        "lua-language-server",
        "stylua",
        "bash-language-server",
        "shellcheck",
        "shfmt",
      },
    },
  },
  {
    "neovim/nvim-lspconfig",
    config = function()
      require "configs.lspconfig"
    end,
  },
  {
    "mrcjkb/rustaceanvim",
    version = "^7",
    lazy = false,
    config = function()
      local cfg = require "rustaceanvim.config"

      -- Use Neovim's standard data path to find the Mason package directly
      -- This prevents the nil crash if Mason hasn't initialized or downloaded it yet
      local mason_path = vim.fn.stdpath "data" .. "/mason/packages/codelldb/extension/"
      local codelldb_path = mason_path .. "adapter/codelldb"
      local liblldb_path = mason_path .. "lldb/lib/liblldb.so"

      vim.g.rustaceanvim = {
        server = {
          on_attach = function(client, bufnr)
            if client.server_capabilities.inlayHintProvider then
              vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })
            end

            -- Custom Rust Keymaps
            local map = function(mode, keys, func, desc)
              vim.keymap.set(mode, keys, func, { buffer = bufnr, desc = "Rust: " .. desc })
            end

            map("n", "<leader>ca", function()
              vim.cmd.RustLsp "codeAction"
            end, "Code Action")
            map("n", "<leader>dr", function()
              vim.cmd.RustLsp "debuggables"
            end, "Debuggables")
            map("n", "<leader>rr", function()
              vim.cmd.RustLsp "runnables"
            end, "Runnables")
            map("n", "<leader>em", function()
              vim.cmd.RustLsp "expandMacro"
            end, "Expand Macro")
            map("n", "K", function()
              vim.cmd.RustLsp { "hover", "actions" }
            end, "Hover Actions")
          end,
          default_settings = {
            ["rust-analyzer"] = {
              check = { command = "clippy" },
            },
          },
        },
        dap = {
          adapter = cfg.get_codelldb_adapter(codelldb_path, liblldb_path),
        },
      }
    end,
  },

  {
    "folke/trouble.nvim",
    opts = {}, -- for default options, refer to the configuration section for custom setup.
    cmd = "Trouble",
    keys = {
      {
        "<leader>xx",
        "<cmd>Trouble diagnostics toggle<cr>",
        desc = "Diagnostics (Trouble)",
      },
      {
        "<leader>xX",
        "<cmd>Trouble diagnostics toggle filter.buf=0<cr>",
        desc = "Buffer Diagnostics (Trouble)",
      },
      {
        "<leader>cs",
        "<cmd>Trouble symbols toggle focus=false<cr>",
        desc = "Symbols (Trouble)",
      },
      {
        "<leader>cl",
        "<cmd>Trouble lsp toggle focus=false win.position=right<cr>",
        desc = "LSP Definitions / references / ... (Trouble)",
      },
      {
        "<leader>xL",
        "<cmd>Trouble loclist toggle<cr>",
        desc = "Location List (Trouble)",
      },
      {
        "<leader>xQ",
        "<cmd>Trouble qflist toggle<cr>",
        desc = "Quickfix List (Trouble)",
      },
    },
  },
  {
    "mfussenegger/nvim-dap",
    config = function()
      local dap, dapui = require "dap", require "dapui"
      dap.listeners.before.attach.dapui_config = function()
        dapui.open()
      end
      dap.listeners.before.launch.dapui_config = function()
        dapui.open()
      end
      dap.listeners.before.event_terminated.dapui_config = function()
        dapui.close()
      end
      dap.listeners.before.event_exited.dapui_config = function()
        dapui.close()
      end
    end,
  },

  {
    "rcarriga/nvim-dap-ui",
    dependencies = { "mfussenegger/nvim-dap", "nvim-neotest/nvim-nio" },
    config = function()
      require("dapui").setup()
    end,
  },
  {
    "saecki/crates.nvim",
    tag = "stable",
    config = function()
      require("crates").setup()
    end,
  },

  { import = "nvchad.blink.lazyspec" },

  {
    "nvim-treesitter/nvim-treesitter",
    opts = {
      ensure_installed = {
        "vim",
        "lua",
        "vimdoc",
        "html",
        "css",
        "rust",
        "ron",
        "toml",
        "just",
        "bash",
        "vue",
        "typescript",
        "javascript",
      },
    },
  },
  {
    "stevearc/aerial.nvim",
    opts = {},
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
      "nvim-tree/nvim-web-devicons",
    },
    keys = {
      { "<leader>a", "<cmd>AerialToggle!<CR>", desc = "Toggle Aerial (Code Outline)" },
    },
  },
}

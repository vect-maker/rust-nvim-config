vim.filetype.add {
  extension = { Containerfile = "dockerfile" },
  filename = { ["Containerfile"] = "dockerfile" },
  pattern = {
    [".*%.Containerfile"] = "dockerfile",
    [".*%.containerfile"] = "dockerfile",
  },
}

return {
  {
    "nvim-tree/nvim-tree.lua",
    opts = {
      filesystem_watchers = {
        enable = true,
        ignore_dirs = { "data", "target" },
      },
    },
  },
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
    opts = {},
  },
  {
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    dependencies = { "williamboman/mason.nvim" },
    opts = {
      ensure_installed = {
        "codelldb",
        "lua-language-server",
        "stylua",
        "bash-language-server",
        "shellcheck",
        "shfmt",
      },
      auto_update = false,
      run_on_start = true,
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
    version = "^9",
    lazy = false,
    init = function()
      vim.g.rustaceanvim = function()
        local cfg = require "rustaceanvim.config"
        local mason_path = vim.fn.stdpath "data" .. "/mason/packages/codelldb/extension/"
        local codelldb_path = mason_path .. "adapter/codelldb"
        local liblldb_ext = vim.fn.has "mac" == 1 and ".dylib" or ".so"
        local liblldb_path = mason_path .. "lldb/lib/liblldb" .. liblldb_ext

        local ok, blink = pcall(require, "blink.cmp")
        local capabilities = ok and blink.get_lsp_capabilities() or vim.lsp.protocol.make_client_capabilities()

        return {
          server = {
            capabilities = capabilities,
            on_attach = function(client, bufnr)
              client.server_capabilities.semanticTokensProvider = client.server_capabilities.semanticTokensProvider

              if client.server_capabilities.inlayHintProvider then
                vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })
              end

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
                cargo = {
                  allFeatures = true,
                  loadOutDirsFromCheck = true,
                  buildScripts = { enable = true },
                },
                checkOnSave = true,
                check = {
                  command = "clippy",
                  features = "all",
                },
                procMacro = {
                  enable = true,
                },
                diagnostics = {
                  enable = true,

                  experimental = { enable = false },
                },
              },
            },
          },
          dap = {
            adapter = cfg.get_codelldb_adapter(codelldb_path, liblldb_path),
          },
        }
      end
    end,
  },
  {
    "folke/trouble.nvim",
    opts = {},
    cmd = "Trouble",
    keys = {
      { "<leader>xx", "<cmd>Trouble diagnostics toggle<<cr>", desc = "Diagnostics (Trouble)" },
      { "<leader>xX", "<cmd>Trouble diagnostics toggle filter.buf=0<<cr>", desc = "Buffer Diagnostics (Trouble)" },
      { "<leader>cs", "<cmd>Trouble symbols toggle focus=false<<cr>", desc = "Symbols (Trouble)" },
      {
        "<leader>cl",
        "<cmd>Trouble lsp toggle focus=false win.position=right<<cr>",
        desc = "LSP Definitions / references / ... (Trouble)",
      },
      { "<leader>xL", "<cmd>Trouble loclist toggle<<cr>", desc = "Location List (Trouble)" },
      { "<leader>xQ", "<cmd>Trouble qflist toggle<<cr>", desc = "Quickfix List (Trouble)" },
    },
  },
  {
    "mfussenegger/nvim-dap",
    dependencies = {
      "rcarriga/nvim-dap-ui",
      "nvim-neotest/nvim-nio",
      { "theHamsta/nvim-dap-virtual-text", opts = {} },
    },
    config = function()
      local dap, dapui = require "dap", require "dapui"

      dap.listeners.after.event_initialized["dapui_config"] = function()
        dapui.open()
      end
      dap.listeners.before.event_terminated["dapui_config"] = function()
        dapui.close()
      end
      dap.listeners.before.event_exited["dapui_config"] = function()
        dapui.close()
      end
    end,
  },
  {
    "rcarriga/nvim-dap-ui",
    dependencies = { "nvim-neotest/nvim-nio" },
    opts = {},
    config = function(_, opts)
      require("dapui").setup(opts)
    end,
  },
  {
    "saecki/crates.nvim",
    tag = "stable",
    event = { "BufRead Cargo.toml" },
    config = function()
      require("crates").setup()
    end,
  },
  { import = "nvchad.blink.lazyspec" },
  {
    "nvim-treesitter/nvim-treesitter",
    lazy = false,
    build = ":TSUpdate",
    config = function()
      require("nvim-treesitter").install {
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
        "dockerfile",
      }
    end,
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

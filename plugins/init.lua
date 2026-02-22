return {
  {
    "stevearc/conform.nvim",
    -- event = 'BufWritePre', -- uncomment for format on save
    opts = require "configs.conform",
  },
 {
    "williamboman/mason.nvim",
    opts = {
      ensure_installed = { "codelldb" }, -- The Rust/C++ debugger
    },
  },
  {
    "neovim/nvim-lspconfig",
    config = function()
      require "configs.lspconfig"
    end,
  },
  {
   'mrcjkb/rustaceanvim',
    version = '^7', 
    lazy = false, 
    config = function()
      local cfg = require('rustaceanvim.config')
      
      -- Use Neovim's standard data path to find the Mason package directly
      -- This prevents the nil crash if Mason hasn't initialized or downloaded it yet
      local mason_path = vim.fn.stdpath("data") .. "/mason/packages/codelldb/extension/"
      local codelldb_path = mason_path .. "adapter/codelldb"
      local liblldb_path = mason_path .. "lldb/lib/liblldb.so"

      vim.g.rustaceanvim = {
        server = {
          on_attach = function(client, bufnr)
            if client.server_capabilities.inlayHintProvider then
              vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })
            end
          end,
          default_settings = {
            ['rust-analyzer'] = {
              checkOnSave = { command = "clippy" }, 
            },
          },
        },
        dap = {
          adapter = cfg.get_codelldb_adapter(codelldb_path, liblldb_path),
        },
      }
    end
 },
  {
    'rust-lang/rust.vim',
    ft = "rust",
    init = function ()
      vim.g.rustfmt_autosave = 1
    end
  },

  {
    "folke/trouble.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    opts = {},
    cmd = "Trouble",
    keys = {
      { "<leader>xx", "<cmd>Trouble diagnostics toggle<cr>", desc = "Diagnostics (Trouble)" },
    },
  },
{
    'mfussenegger/nvim-dap',
    config = function()
			local dap, dapui = require("dap"), require("dapui")
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
    'rcarriga/nvim-dap-ui', 
    dependencies = {"mfussenegger/nvim-dap", "nvim-neotest/nvim-nio"},
    config = function()
			require("dapui").setup()
		end,
  },
  {
    'saecki/crates.nvim',
    tag = 'stable',
    config = function()
        require('crates').setup()
    end,
},


  
   { import = "nvchad.blink.lazyspec" },

   {
   	"nvim-treesitter/nvim-treesitter",
   	opts = {
  		ensure_installed = {
 			"vim", "lua", "vimdoc",
        "html", "css"
   		},
   	},
   },
}

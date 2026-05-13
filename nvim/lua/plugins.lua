local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  local out = vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath,
  })
  if vim.v.shell_error ~= 0 then
    error("Failed to clone lazy.nvim:\n" .. out)
  end
end
vim.opt.rtp:prepend(lazypath)

vim.g.lazy_plugins = {}

require("lazy").setup({
  -- Colorscheme
  { "folke/tokyonight.nvim", lazy = false, priority = 1000, opts = { style = "night" } },

  -- Treesitter
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    config = function()
      local ok, err = pcall(function()
        require("nvim-treesitter.configs").setup({
          ensure_installed = { "lua", "python", "markdown", "markdown_inline" },
          auto_install = true,
          highlight = { enable = true },
          indent = { enable = true },
        })
      end)
      if not ok then
        vim.notify("nvim-treesitter not ready yet: " .. err, vim.log.levels.WARN)
      end
    end,
  },

  -- LSP
  { "williamboman/mason.nvim", build = ":MasonUpdate", opts = {} },
  "williamboman/mason-lspconfig.nvim",
  "neovim/nvim-lspconfig",

  -- Autocompletion
  {
    "hrsh7th/nvim-cmp",
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",
      "L3MON4D3/LuaSnip",
      "saadparwaiz1/cmp_luasnip",
    },
    config = function()
      local cmp = require("cmp")
      local luasnip = require("luasnip")

      cmp.setup({
        snippet = {
          expand = function(args)
            luasnip.lsp_expand(args.body)
          end,
        },
        mapping = cmp.mapping.preset.insert({
          ["<C-b>"] = cmp.mapping.scroll_docs(-4),
          ["<C-f>"] = cmp.mapping.scroll_docs(4),
          ["<C-Space>"] = cmp.mapping.complete(),
          ["<C-e>"] = cmp.mapping.abort(),
          ["<CR>"] = cmp.mapping.confirm({ select = true }),
          ["<Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_next_item()
            elseif luasnip.expand_or_jumpable() then
              luasnip.expand_or_jump()
            else
              fallback()
            end
          end, { "i", "s" }),
          ["<S-Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_prev_item()
            elseif luasnip.jumpable(-1) then
              luasnip.jump(-1)
            else
              fallback()
            end
          end, { "i", "s" }),
        }),
        sources = cmp.config.sources({
          { name = "nvim_lsp" },
          { name = "luasnip" },
        }, {
          { name = "buffer" },
          { name = "path" },
        }),
      })
    end,
  },

  -- Formatter
  {
    "stevearc/conform.nvim",
    opts = {
      formatters_by_ft = {
        python = { "ruff_format" },
        lua = { "stylua" },
      },
      format_on_save = { timeout_ms = 500 },
    },
  },

  -- Telescope
  {
    "nvim-telescope/telescope.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      local builtin = require("telescope.builtin")
      vim.keymap.set("n", "<Space>ff", builtin.find_files, { desc = "Find files" })
      vim.keymap.set("n", "<Space>fg", builtin.live_grep, { desc = "Live grep" })
      vim.keymap.set("n", "<Space>fb", builtin.buffers, { desc = "Buffers" })
      vim.keymap.set("n", "<Space>fh", builtin.help_tags, { desc = "Help tags" })
    end,
  },

  -- File explorer
  {
    "stevearc/oil.nvim",
    opts = {},
    config = function()
      vim.keymap.set("n", "<Space>e", "<cmd>Oil<CR>", { desc = "File explorer" })
    end,
  },

  -- Git signs
  {
    "lewis6991/gitsigns.nvim",
    opts = {},
  },

  -- Debugger
  {
    "mfussenegger/nvim-dap",
    config = function()
      local dap = require("dap")
      local python_cmd = vim.fn.executable("python3") == 1 and "python3" or "python"
      dap.adapters.python = {
        type = "executable",
        command = python_cmd,
        args = { "-m", "debugpy.adapter" },
      }
      dap.configurations.python = {
        {
          type = "python",
          request = "launch",
          name = "Launch file",
          program = "${file}",
        },
        {
          type = "python",
          request = "test",
          name = "Pytest (file)",
          program = "${file}",
        },
      },
      vim.keymap.set("n", "<F5>", "<cmd>lua require('dap').continue()<CR>", { desc = "Debug continue" })
      vim.keymap.set("n", "<F10>", "<cmd>lua require('dap').step_over()<CR>", { desc = "Debug step over" })
      vim.keymap.set("n", "<F11>", "<cmd>lua require('dap').step_into()<CR>", { desc = "Debug step into" })
      vim.keymap.set("n", "<F12>", "<cmd>lua require('dap').step_out()<CR>", { desc = "Debug step out" })
    end,
  },
  "mfussenegger/nvim-dap-python",
  {
    "rcarriga/nvim-dap-ui",
    dependencies = { "mfussenegger/nvim-dap" },
    config = function()
      require("dapui").setup()
      local dap, dapui = require("dap"), require("dapui")
      dap.listeners.after.event_initialized["dapui"] = dapui.open
      dap.listeners.before.event_terminated["dapui"] = dapui.close
      dap.listeners.before.event_exited["dapui"] = dapui.close
    end,
  },
  {
    "theHamsta/nvim-dap-virtual-text",
    opts = {},
  },

  -- Test runner
  {
    "nvim-neotest/neotest",
    dependencies = {
      "nvim-neotest/nvim-nio",
      "nvim-lua/plenary.nvim",
      "nvim-neotest/neotest-python",
    },
    config = function()
      require("neotest").setup({
        adapters = {
          require("neotest-python")({
            dap = { justMyCode = false },
          }),
        },
      })
      local neotest = require("neotest")
      vim.keymap.set("n", "<Space>tl", function() neotest.run.run() end, { desc = "Test nearest" })
      vim.keymap.set("n", "<Space>tf", function() neotest.run.run(vim.fn.expand("%")) end, { desc = "Test file" })
      vim.keymap.set("n", "<Space>ts", neotest.run.stop, { desc = "Test stop" })
      vim.keymap.set("n", "<Space>to", neotest.output.open, { desc = "Test output" })
    end,
  },

  -- UI
  { "folke/which-key.nvim", opts = {} },
  { "nvim-tree/nvim-web-devicons", lazy = true },
  {
    "lukas-reineke/indent-blankline.nvim",
    main = "ibl",
    opts = {},
  },
  {
    "windwp/nvim-autopairs",
    config = function()
      require("nvim-autopairs").setup()
    end,
  },
})

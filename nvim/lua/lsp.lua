-- LSP keymaps
local on_attach = function(client, bufnr)
  local map = function(mode, lhs, rhs, desc)
    vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, desc = "LSP: " .. desc })
  end

  map("n", "gd", vim.lsp.buf.definition, "Go to definition")
  map("n", "gD", vim.lsp.buf.declaration, "Go to declaration")
  map("n", "gr", vim.lsp.buf.references, "References")
  map("n", "gi", vim.lsp.buf.implementation, "Go to implementation")
  map("n", "K", vim.lsp.buf.hover, "Hover documentation")
  map("n", "<C-k>", vim.lsp.buf.signature_help, "Signature help")
  map("n", "<Space>wa", vim.lsp.buf.add_workspace_folder, "Add workspace folder")
  map("n", "<Space>wr", vim.lsp.buf.remove_workspace_folder, "Remove workspace folder")
  map("n", "<Space>wl", function() print(vim.inspect(vim.lsp.buf.list_workspace_folders())) end, "List workspace folders")
  map("n", "<Space>rn", vim.lsp.buf.rename, "Rename")
  map({ "n", "x" }, "<Space>ca", vim.lsp.buf.code_action, "Code action")
  map("n", "<Space>f", function() vim.lsp.buf.format({ async = true }) end, "Format")
  map("n", "gl", vim.diagnostic.open_float, "Line diagnostics")
  map("n", "[d", vim.diagnostic.goto_prev, "Previous diagnostic")
  map("n", "]d", vim.diagnostic.goto_next, "Next diagnostic")
end

-- Mason: auto-install and configure LSP servers
require("mason").setup()
require("mason-lspconfig").setup({
  ensure_installed = { "pyright" },
  automatic_installation = true,
  handlers = {
    function(server_name)
      local lspconfig = require("lspconfig")
      lspconfig[server_name].setup({
        on_attach = on_attach,
        capabilities = require("cmp_nvim_lsp").default_capabilities(),
      })
    end,
  },
})

-- Better diagnostics signs
local signs = { Error = "✘", Warn = "▲", Hint = "⚑", Info = "ℹ" }
for type, icon in pairs(signs) do
  local hl = "DiagnosticSign" .. type
  vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = hl })
end

vim.diagnostic.config({
  virtual_text = true,
  signs = true,
  update_in_insert = false,
  severity_sort = true,
  float = { border = "rounded" },
})

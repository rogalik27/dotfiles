return {{
  "williamboman/mason.nvim",
  opts = {
    ui = {
      icons = {
        package_installed = "✓",
        package_pending = "➜",
        package_uninstalled = "✗"
      }
    }
  }
}, {
  "williamboman/mason-lspconfig.nvim",
  dependencies = { "neovim/nvim-lspconfig" },
  opts = {}
}, {
  "neovim/nvim-lspconfig",
  dependencies = {
    "williamboman/mason.nvim",
    "williamboman/mason-lspconfig.nvim",
  },
  config = function()
    local lspconfig = require("lspconfig")
    local registry = require("mason-registry")
    local get_mappings = require("mason-lspconfig").get_mappings

    local on_attach = function(_, _)
      vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, { desc = "Rename" })
      vim.keymap.set('n', '<leader>ca', vim.lsp.buf.code_action, { desc = "Code Action" })
      vim.keymap.set('n', 'gd', vim.lsp.buf.definition, { desc = "Definition" })
      vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, { desc = "Implementation" })
      vim.keymap.set('n', 'gr', require('telescope.builtin').lsp_references, { desc = "References" })
      vim.keymap.set('n', 'K', vim.lsp.buf.hover, { desc = "Hover" })
    end

    require("mason").setup()
    require("mason-lspconfig").setup()

    local mappings = get_mappings()

    for _, pkg in ipairs(registry.get_installed_packages()) do
      local mason_name = pkg.name
      local lsp_name = mappings[mason_name]
      if lsp_name and lspconfig[lsp_name] then
        lspconfig[lsp_name].setup({
          on_attach = on_attach,
        })
      end
    end
  end
}}


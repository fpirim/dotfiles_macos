return {
  {
    "nvimtools/none-ls.nvim",
    config = function()
      local null_ls = require("null-ls")
      null_ls.setup({
        null_ls.builtins.formatting.stylua,
        null_ls.builtins.formatting.eslint_d,
        null_ls.builtins.formatting.prettier,
      })

      vim.keymap.set('n', '<leader>gf', vim.lsp.buf.format, {})
    end
  },
  {
    "jay-babu/mason-null-ls.nvim",
    dependencies = { "williamboman/mason.nvim", "jose-elias-alvarez/null-ls.nvim" },
    config = function()
      require("mason-null-ls").setup({
        ensure_installed = { "stylua", "prettier", "eslint_d" },
        automatic_installation = true,
      })
    end
  }
}

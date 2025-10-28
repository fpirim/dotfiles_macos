return {
  {
    "williamboman/mason.nvim",
    config = function()
      require("mason").setup()
    end
  },
  {
    "williamboman/mason-lspconfig.nvim",
    config = function()
      require("mason-lspconfig").setup({
        ensure_installed = { "lua_ls", "ts_ls", "yamlls" }
      })
    end
  },
  {
    "neovim/nvim-lspconfig",
    config = function()
      -- Use the new vim.lsp.config API (neovim 0.11+)

      -- Configure Lua Language Server
      vim.lsp.config.lua_ls = {
        cmd = { "lua-language-server" },
        filetypes = { "lua" },
        root_markers = { ".luarc.json", ".luarc.jsonc", ".luacheckrc", ".stylua.toml", "stylua.toml", "selene.toml", "selene.yml", ".git" },
        settings = {
          Lua = {
            diagnostics = {
              globals = { "vim" }, -- Fix undefined global 'vim'
            }
          }
        }
      }

      vim.lsp.config.ts_ls = {
        cmd = { "typescript-language-server", "--stdio" },
        filetypes = { "javascript", "javascriptreact", "javascript.jsx", "typescript", "typescriptreact", "typescript.tsx" },
        root_markers = { "package.json", "tsconfig.json", "jsconfig.json", ".git" },
      }

      vim.lsp.config.yamlls = {
        cmd = { "yaml-language-server", "--stdio" },
        filetypes = { "yaml", "yaml.docker-compose" },
        root_markers = { ".git" },
        settings = {
          yaml = {
            ["https://json.schemastore.org/github-workflow.json"] = "/.github/workflows/*",
            ["https://raw.githubusercontent.com/yannh/kubernetes-json-schema/refs/heads/master/v1.32.1-standalone-strict/all.json"] =
            "/*.k8s.yaml",
          },
        }
      }

      -- Enable the LSP servers
      vim.lsp.enable("lua_ls")
      vim.lsp.enable("ts_ls")
      vim.lsp.enable("yamlls")

      vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, {})
      vim.keymap.set('n', 'gd', vim.lsp.buf.definition, {})
      vim.keymap.set('n', 'K', vim.lsp.buf.hover, {})
      vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, {})
      vim.keymap.set('n', '<C-k>', vim.lsp.buf.signature_help, {})
      vim.keymap.set('n', '<space>wa', vim.lsp.buf.add_workspace_folder, {})
      vim.keymap.set('n', '<space>wr', vim.lsp.buf.remove_workspace_folder, {})
      vim.keymap.set('n', '<space>D', vim.lsp.buf.type_definition, {})
      vim.keymap.set('n', '<space>rn', vim.lsp.buf.rename, {})
      vim.keymap.set('n', '<space>ca', vim.lsp.buf.code_action, {})
      vim.keymap.set('n', 'gr', vim.lsp.buf.references, {})
    end
  }
}

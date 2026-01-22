local lspconfig = require("lspconfig")

local on_attach = function(_, bufnr)
  local opts = { buffer = bufnr }

  vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
  vim.keymap.set("n", "gr", vim.lsp.buf.references, opts)
  vim.keymap.set("n", "gi", vim.lsp.buf.implementation, opts)
  vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
  vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)
  vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, opts)
end

local capabilities =
  require("cmp_nvim_lsp").default_capabilities()

lspconfig.gopls.setup({
  on_attach = on_attach,
  capabilities = capabilities,
  settings = {
    gopls = {
      gofumpt = true,
      usePlaceholders = true,
      completeUnimported = true,
      staticcheck = true,
      analyses = {
        unusedparams = true,
        nilness = true,
        unusedwrite = true,
        shadow = true,
      },
      hints = {
        assignVariableTypes = true,
        compositeLiteralFields = true,
        compositeLiteralTypes = true,
        parameterNames = true,
        rangeVariableTypes = true,
      },
    },
  },
})


-- -- keymaps & common settings
-- local on_attach = function(client, bufnr)
--   local opts = { buffer = bufnr, remap = false }
-- 
--   vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
--   vim.keymap.set("n", "gr", vim.lsp.buf.references, opts)
--   vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
--   vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)
-- end
-- 
-- local capabilities = vim.lsp.protocol.make_client_capabilities()
-- capabilities = require("cmp_nvim_lsp").default_capabilities(capabilities)
-- 
-- local servers = {
--   lua_ls = {},
--   pyright = {},
--   rust_analyzer = {},
--   tsserver = {},
--   gopls = {},
--   clangd = {},
-- }
-- 
-- for lsp, config in pairs(servers) do
--   config.on_attach = on_attach
--   config.capabilities = capabilities
--   require("lspconfig")[lsp].setup(config)
-- end
-- 

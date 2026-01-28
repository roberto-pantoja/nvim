-- LSP Configuration using Neovim 0.11+ vim.lsp.config API
-- Properly starts LSP servers with autocmd triggers

local on_attach = function(client, bufnr)
  local opts = { buffer = bufnr }

  -- LSP keybindings
  vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
  vim.keymap.set("n", "gr", vim.lsp.buf.references, opts)
  vim.keymap.set("n", "gi", vim.lsp.buf.implementation, opts)
  vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
  vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)
  vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, opts)
  
  -- Additional useful keybindings
  vim.keymap.set("n", "<leader>f", function() 
    vim.lsp.buf.format({ async = true }) 
  end, opts)
  vim.keymap.set("n", "<leader>d", vim.diagnostic.open_float, opts)
  vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, opts)
  vim.keymap.set("n", "]d", vim.diagnostic.goto_next, opts)

  -- Enable completion triggered by <c-x><c-o>
  if client.server_capabilities.completionProvider then
    vim.bo[bufnr].omnifunc = "v:lua.vim.lsp.omnifunc"
  end
end

-- Set up completion capabilities
local capabilities = require("cmp_nvim_lsp").default_capabilities()

-- Enhance completion capabilities
capabilities.textDocument.completion.completionItem = {
  documentationFormat = { "markdown", "plaintext" },
  snippetSupport = true,
  preselectSupport = true,
  insertReplaceSupport = true,
  labelDetailsSupport = true,
  deprecatedSupport = true,
  commitCharactersSupport = true,
  tagSupport = { valueSet = { 1 } },
  resolveSupport = {
    properties = {
      "documentation",
      "detail",
      "additionalTextEdits",
    },
  },
}

-- Configure Go LSP (gopls)
vim.lsp.config.gopls = {
  cmd = { 'gopls' },
  filetypes = { 'go', 'gomod', 'gowork', 'gotmpl' },
  root_markers = { 'go.work', 'go.mod', '.git' },
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
      -- Enable completion features
      experimentalPostfixCompletions = true,
    },
  },
}

-- Configure Lua LSP (lua_ls)
vim.lsp.config.lua_ls = {
  cmd = { 'lua-language-server' },
  filetypes = { 'lua' },
  root_markers = { '.luarc.json', '.luarc.jsonc', '.luacheckrc', '.stylua.toml', 'stylua.toml', 'selene.toml', 'selene.yml', '.git' },
  on_attach = on_attach,
  capabilities = capabilities,
  settings = {
    Lua = {
      runtime = { version = 'LuaJIT' },
      diagnostics = { globals = { 'vim' } },
      workspace = {
        library = vim.api.nvim_get_runtime_file("", true),
        checkThirdParty = false,
      },
      telemetry = { enable = false },
      completion = {
        callSnippet = "Replace"
      },
    },
  },
}

-- Configure Python LSP (pyright)
vim.lsp.config.pyright = {
  cmd = { 'pyright-langserver', '--stdio' },
  filetypes = { 'python' },
  root_markers = { 'pyproject.toml', 'setup.py', 'setup.cfg', 'requirements.txt', 'Pipfile', 'pyrightconfig.json', '.git' },
  on_attach = on_attach,
  capabilities = capabilities,
  settings = {
    python = {
      analysis = {
        autoSearchPaths = true,
        useLibraryCodeForTypes = true,
        diagnosticMode = 'workspace',
      }
    }
  }
}

-- Configure Rust LSP (rust_analyzer)
vim.lsp.config.rust_analyzer = {
  cmd = { 'rust-analyzer' },
  filetypes = { 'rust' },
  root_markers = { 'Cargo.toml', 'rust-project.json' },
  on_attach = on_attach,
  capabilities = capabilities,
}

-- Configure TypeScript LSP (ts_ls)
vim.lsp.config.ts_ls = {
  cmd = { 'typescript-language-server', '--stdio' },
  filetypes = { 'javascript', 'javascriptreact', 'javascript.jsx', 'typescript', 'typescriptreact', 'typescript.tsx' },
  root_markers = { 'tsconfig.json', 'package.json', 'jsconfig.json', '.git' },
  on_attach = on_attach,
  capabilities = capabilities,
}

-- Configure C/C++ LSP (clangd)
vim.lsp.config.clangd = {
  cmd = { 'clangd' },
  filetypes = { 'c', 'cpp', 'objc', 'objcpp', 'cuda', 'proto' },
  root_markers = { '.clangd', '.clang-tidy', '.clang-format', 'compile_commands.json', 'compile_flags.txt', 'configure.ac', '.git' },
  on_attach = on_attach,
  capabilities = capabilities,
}

-- Create autocmds to start LSP servers when opening supported files
local lsp_group = vim.api.nvim_create_augroup("LspStartup", { clear = true })

-- Helper function to start LSP for a buffer
local function start_lsp(server_name, bufnr)
  bufnr = bufnr or vim.api.nvim_get_current_buf()
  local config = vim.lsp.config[server_name]
  if config then
    vim.lsp.start({
      name = server_name,
      cmd = config.cmd,
      root_dir = vim.fs.find(config.root_markers, {
        upward = true,
        path = vim.fs.dirname(vim.api.nvim_buf_get_name(bufnr))
      })[1],
      on_attach = config.on_attach,
      capabilities = config.capabilities,
      settings = config.settings,
    }, { bufnr = bufnr })
  end
end

-- Start LSP servers automatically based on filetype
vim.api.nvim_create_autocmd({ "BufReadPost", "BufNewFile" }, {
  group = lsp_group,
  pattern = { "*.go", "*.mod", "*.work" },
  callback = function(args)
    start_lsp("gopls", args.buf)
  end,
})

vim.api.nvim_create_autocmd({ "BufReadPost", "BufNewFile" }, {
  group = lsp_group,
  pattern = "*.lua",
  callback = function(args)
    start_lsp("lua_ls", args.buf)
  end,
})

vim.api.nvim_create_autocmd({ "BufReadPost", "BufNewFile" }, {
  group = lsp_group,
  pattern = "*.py",
  callback = function(args)
    start_lsp("pyright", args.buf)
  end,
})

vim.api.nvim_create_autocmd({ "BufReadPost", "BufNewFile" }, {
  group = lsp_group,
  pattern = "*.rs",
  callback = function(args)
    start_lsp("rust_analyzer", args.buf)
  end,
})

vim.api.nvim_create_autocmd({ "BufReadPost", "BufNewFile" }, {
  group = lsp_group,
  pattern = { "*.ts", "*.tsx", "*.js", "*.jsx" },
  callback = function(args)
    start_lsp("ts_ls", args.buf)
  end,
})

vim.api.nvim_create_autocmd({ "BufReadPost", "BufNewFile" }, {
  group = lsp_group,
  pattern = { "*.c", "*.cpp", "*.h", "*.hpp" },
  callback = function(args)
    start_lsp("clangd", args.buf)
  end,
})

-- LSP diagnostic signs with better icons (using modern API)
vim.diagnostic.config({
  virtual_text = {
    source = "always",
    prefix = "●",
  },
  signs = {
    text = {
      [vim.diagnostic.severity.ERROR] = "",
      [vim.diagnostic.severity.WARN] = "",
      [vim.diagnostic.severity.HINT] = "💡",
      [vim.diagnostic.severity.INFO] = "",
    }
  },
  underline = true,
  update_in_insert = false,
  severity_sort = true,
  float = {
    border = "rounded",
    source = "always",
    header = "",
    prefix = "",
  },
})
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

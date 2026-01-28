return {
  "williamboman/mason.nvim",
  config = function()
    require("mason").setup({
      ui = {
        icons = {
          package_installed = "✓",
          package_pending = "➜",
          package_uninstalled = "✗"
        }
      }
    })

    -- Install LSP servers manually through Mason
    local ensure_installed = {
      "lua-language-server",
      "pyright", 
      "rust-analyzer",
      "typescript-language-server",
      "gopls",
      "clangd",
    }

    local mason_registry = require("mason-registry")
    for _, server in ipairs(ensure_installed) do
      local p = mason_registry.get_package(server)
      if not p:is_installed() then
        p:install()
      end
    end

    -- Ensure tools are available after installation
    vim.api.nvim_create_autocmd("User", {
      pattern = "MasonToolsUpdateCompleted",
      callback = function()
        vim.schedule(function()
          print("Mason tools updated")
        end)
      end,
    })
  end,
}


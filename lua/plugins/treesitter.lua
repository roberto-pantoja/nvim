return {
  'nvim-treesitter/nvim-treesitter',
  lazy = false,
  build = ':TSUpdate',
  opts = {
    ensure_installed = {
      "lua",
      "vim",
      "vimdoc",
      "bash",
      "json",
      "yaml",
      "go",
      "gomod",
      "gosum",
      "gowork",
    },
    highlight = { enable = true },
    indent = { enable = true },
  },
}

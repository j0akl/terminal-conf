-- Treesitter: AST-based syntax highlighting & indentation (biggest readability win)
return {
  "nvim-treesitter/nvim-treesitter",
  branch = "master",
  build = ":TSUpdate",
  event = { "BufReadPost", "BufNewFile" },
  config = function()
    require("nvim-treesitter.configs").setup({
      ensure_installed = {
        "python",
        "typescript",
        "tsx",
        "javascript",
        "json",
        "jsonc",
        "lua",
        "markdown",
        "markdown_inline",
        "html",
        "css",
        "yaml",
        "toml",
        "bash",
        "vim",
        "vimdoc",
      },
      auto_install = true,
      highlight = { enable = true },
      indent = { enable = true },
    })
  end,
}

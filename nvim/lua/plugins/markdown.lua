-- Render markdown inline (headings, code blocks, tables) — great for reading
-- Claude Code plans, docs, and docstrings.
return {
  "MeanderingProgrammer/render-markdown.nvim",
  dependencies = {
    "nvim-treesitter/nvim-treesitter",
    "nvim-tree/nvim-web-devicons",
  },
  ft = { "markdown" },
  config = function()
    require("render-markdown").setup({
      -- Render in normal mode; show raw text when you're editing the line
      render_modes = { "n", "c" },
    })
  end,
}

-- Diff viewer: review all working changes side-by-side, browse git history.
-- Great for reviewing what Claude Code edited before committing.
return {
  "sindrets/diffview.nvim",
  dependencies = { "nvim-lua/plenary.nvim" },
  cmd = { "DiffviewOpen", "DiffviewClose", "DiffviewFileHistory" },
  keys = {
    { "<leader>gd", "<cmd>DiffviewOpen<CR>", desc = "Diff working changes" },
    { "<leader>gh", "<cmd>DiffviewFileHistory %<CR>", desc = "File history (current)" },
    { "<leader>gH", "<cmd>DiffviewFileHistory<CR>", desc = "Repo history" },
    { "<leader>gc", "<cmd>DiffviewClose<CR>", desc = "Close diff view" },
  },
  config = function()
    require("diffview").setup({
      enhanced_diff_hl = true,
    })
  end,
}

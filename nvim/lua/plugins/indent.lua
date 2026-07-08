-- Subtle indentation guides — readability, especially for Python
return {
  "lukas-reineke/indent-blankline.nvim",
  main = "ibl",
  event = { "BufReadPost", "BufNewFile" },
  config = function()
    require("ibl").setup({
      indent = { char = "│" },
      scope = { enabled = true, show_start = false, show_end = false },
    })
  end,
}

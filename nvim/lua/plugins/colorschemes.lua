-- Dark colorschemes. rose-pine is the default (applied below). The others load
-- at startup (without applying) so their variants show up in the <leader>uc
-- picker. To change the default, move the colorscheme() call to another spec.
return {
  {
    "rose-pine/neovim",
    name = "rose-pine",
    lazy = false,
    priority = 1000,
    config = function()
      require("rose-pine").setup({ variant = "main" }) -- main = dark
      vim.cmd.colorscheme("rose-pine")
    end,
  },
  {
    "catppuccin/nvim",
    name = "catppuccin",
    lazy = false,
    priority = 900,
    opts = { flavour = "mocha" },
  },
  {
    "rebelot/kanagawa.nvim",
    lazy = false,
    priority = 900,
  },
}

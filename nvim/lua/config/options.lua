vim.g.mapleader = " "
vim.g.maplocalleader = " "

local opt = vim.opt

opt.number = true
opt.relativenumber = true

opt.tabstop = 4
opt.shiftwidth = 4
opt.expandtab = true
opt.smartindent = true

opt.wrap = false
opt.termguicolors = true
opt.cursorline = true
opt.signcolumn = "yes"
opt.laststatus = 2 -- statusline per window/split

opt.scrolloff = 8
opt.sidescrolloff = 8

opt.ignorecase = true
opt.smartcase = true

opt.updatetime = 250
opt.timeoutlen = 400

opt.splitright = true
opt.splitbelow = true

opt.clipboard = "unnamedplus"

opt.swapfile = false
opt.backup = false
opt.undofile = true

opt.completeopt = { "menu", "menuone", "noselect" }

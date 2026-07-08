local keymap = vim.keymap.set

-- Better escape
keymap("i", "jk", "<Esc>", { desc = "Exit insert mode" })

-- Save / quit
keymap("n", "<leader>w", "<cmd>w<CR>", { desc = "Save file" })
keymap("n", "<leader>q", "<cmd>q<CR>", { desc = "Quit" })

-- Clear search highlight
keymap("n", "<Esc>", "<cmd>nohlsearch<CR>", { desc = "Clear search highlight" })

-- Live colorscheme picker (preview as you scroll)
keymap("n", "<leader>uc", "<cmd>Telescope colorscheme enable_preview=true<CR>", { desc = "Pick colorscheme" })

-- Window navigation
keymap("n", "<C-h>", "<C-w>h", { desc = "Move to left window" })
keymap("n", "<C-j>", "<C-w>j", { desc = "Move to lower window" })
keymap("n", "<C-k>", "<C-w>k", { desc = "Move to upper window" })
keymap("n", "<C-l>", "<C-w>l", { desc = "Move to right window" })

-- Resize windows
keymap("n", "<leader>+", "<cmd>resize +5<CR>", { desc = "Increase window height" })
keymap("n", "<leader>-", "<cmd>resize -5<CR>", { desc = "Decrease window height" })
keymap("n", "<leader>>", "<cmd>vertical resize +5<CR>", { desc = "Increase window width" })
keymap("n", "<leader><", "<cmd>vertical resize -5<CR>", { desc = "Decrease window width" })

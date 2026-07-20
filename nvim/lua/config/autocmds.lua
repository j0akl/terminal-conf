-- Auto-reload files changed on disk (e.g. when Claude Code edits them)
vim.opt.autoread = true

local reload = vim.api.nvim_create_augroup("auto_reload", { clear = true })

-- Check for external changes on these events and reload the buffer if needed
vim.api.nvim_create_autocmd({ "FocusGained", "BufEnter", "CursorHold", "CursorHoldI" }, {
  group = reload,
  callback = function()
    -- Don't run in command-line window or while typing a command
    if vim.fn.mode() ~= "c" and vim.fn.getcmdwintype() == "" then
      vim.cmd("silent! checktime")
    end
  end,
})

-- Notify when a buffer was reloaded from disk
vim.api.nvim_create_autocmd("FileChangedShellPost", {
  group = reload,
  callback = function()
    vim.notify("File changed on disk — buffer reloaded", vim.log.levels.INFO)
  end,
})

-- Enable soft line wrapping for prose filetypes (wrap is off globally)
vim.api.nvim_create_autocmd("FileType", {
  group = vim.api.nvim_create_augroup("prose_wrap", { clear = true }),
  pattern = { "markdown", "text", "gitcommit" },
  callback = function()
    vim.opt_local.wrap = true
    vim.opt_local.linebreak = true -- break at word boundaries, not mid-word
  end,
})

-- Briefly highlight yanked text (nice readability touch)
vim.api.nvim_create_autocmd("TextYankPost", {
  group = vim.api.nvim_create_augroup("highlight_yank", { clear = true }),
  callback = function()
    vim.highlight.on_yank({ timeout = 150 })
  end,
})

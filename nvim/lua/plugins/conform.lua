-- Formatting: route each filetype to the right formatter with format-on-save.
-- Python -> ruff (via mason). TS/JS -> prettier if available, else LSP.
return {
  "stevearc/conform.nvim",
  event = { "BufWritePre" },
  cmd = { "ConformInfo" },
  keys = {
    {
      "<leader>cf",
      function()
        require("conform").format({ async = true, lsp_format = "fallback" })
      end,
      mode = { "n", "v" },
      desc = "Format buffer",
    },
  },
  config = function()
    require("conform").setup({
      formatters_by_ft = {
        python = { "ruff_organize_imports", "ruff_format" },
        javascript = { "prettierd", "prettier", stop_after_first = true },
        typescript = { "prettierd", "prettier", stop_after_first = true },
        javascriptreact = { "prettierd", "prettier", stop_after_first = true },
        typescriptreact = { "prettierd", "prettier", stop_after_first = true },
        json = { "prettierd", "prettier", stop_after_first = true },
        markdown = { "prettierd", "prettier", stop_after_first = true },
        lua = { "stylua" },
      },
      -- If no formatter is installed for a filetype, fall back to the LSP.
      format_on_save = {
        timeout_ms = 1000,
        lsp_format = "fallback",
      },
    })
  end,
}

-- Treesitter: AST-based syntax highlighting & indentation (biggest readability win).
--
-- Uses the `main` branch. The old `master` branch is archived and explicitly
-- does NOT support Neovim 0.12+ (its query predicates crash on markdown
-- injections: "attempt to call method 'range' (a nil value)"), which broke
-- markdown highlighting and render-markdown.nvim.
--
-- On `main` the API changed: no more `nvim-treesitter.configs.setup`. Parsers
-- are installed with `.install()`, and highlighting/indent are Neovim features
-- enabled per-buffer via a FileType autocmd.
local ensure_installed = {
  "python",
  "typescript",
  "tsx",
  "javascript",
  "json",
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
}

return {
  "nvim-treesitter/nvim-treesitter",
  branch = "main",
  lazy = false, -- the main branch does not support lazy-loading
  build = ":TSUpdate",
  config = function()
    require("nvim-treesitter").install(ensure_installed)

    -- `jsonc` has no dedicated parser on the main branch; reuse the json one.
    vim.treesitter.language.register("json", "jsonc")

    vim.api.nvim_create_autocmd("FileType", {
      desc = "Start treesitter highlighting & indentation when a parser exists",
      callback = function(args)
        local buf = args.buf
        local lang = vim.treesitter.language.get_lang(vim.bo[buf].filetype)
        if not lang then
          return
        end
        -- Installs run asynchronously; only start once the parser is available.
        if not pcall(vim.treesitter.start, buf, lang) then
          return
        end
        -- Treesitter-based indentation (experimental, provided by this plugin).
        vim.bo[buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
      end,
    })
  end,
}

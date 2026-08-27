-- Legacy Vim syntax highlighting for Markdown.
-- This avoids Neovim 0.12's Tree-sitter Markdown highlighter crash while
-- preserving Tree-sitter for all other filetypes.
return {
  "preservim/vim-markdown",
  lazy = false,
  dependencies = { "godlygeek/tabular" },
  init = function()
    vim.g.vim_markdown_conceal_code_blocks = 0
    vim.g.vim_markdown_folding_disabled = 1
  end,
}

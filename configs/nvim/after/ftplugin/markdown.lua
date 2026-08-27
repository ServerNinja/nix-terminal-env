-- Neovim's built-in Markdown ftplugin starts Tree-sitter automatically.
-- Stop it after all Markdown ftplugins have loaded; vim-markdown supplies
-- the regular-expression-based syntax highlighting instead.
vim.treesitter.stop()

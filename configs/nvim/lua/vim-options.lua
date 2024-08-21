vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

vim.cmd("set expandtab")
vim.cmd("set tabstop=2")
vim.cmd("set softtabstop=2")
vim.cmd("set shiftwidth=2")

vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

-- Fix vsplit
vim.opt.splitbelow = true
vim.opt.splitright = true

-- Highlight current line
vim.opt.cursorline = true
vim.opt.number = true
vim.opt.termguicolors = true
vim.opt.cursorlineopt = "both"

-- For copilot
vim.g.copilot_assume_mapped = true

-- Open nvim tree every time we open neovim
vim.api.nvim_create_autocmd("VimEnter", {
  callback = function()
    require('nvim-tree.api').tree.open()
  end
})

--Integrate clipboard with system clipboard
vim.opt.clipboard = 'unnamedplus'


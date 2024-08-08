-- File for keymap settings and overrides
local keymap = vim.keymap

-- Nvim-tree
keymap.set('n', '<C-n>', ':NvimTreeFocus<CR>')

-- LazyGit
keymap.set('n', '<leader>lg', '<cmd>LazyGit<cr>', {desc = "LazyGit"})

-- Telescope
keymap.set('n', '<C-p>', '<cmd>Telescope find_files<cr>', {})

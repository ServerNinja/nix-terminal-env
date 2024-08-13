-- File for keymap settings and overrides
local keymap = vim.keymap

-- Nvim-tree
keymap.set('n', '<C-n>', ':NvimTreeFocus<CR>')

-- LazyGit
keymap.set('n', '<leader>lg', '<cmd>LazyGit<cr>', {desc = "LazyGit"})

-- Telescope
keymap.set('n', '<C-p>', '<cmd>Telescope find_files<cr>', {})

-- Rust
local bufnr = vim.api.nvim_get_current_buf()
vim.keymap.set(
  "n", 
  "<leader>a", 
  function()
    vim.cmd.RustLsp('codeAction') -- supports rust-analyzer's grouping
    -- or vim.lsp.buf.codeAction() if you don't want grouping.
  end,
  { silent = true, buffer = bufnr }
)

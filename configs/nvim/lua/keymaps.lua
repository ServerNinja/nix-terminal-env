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

-- WINDOW MANAGEMENT
keymap.set("n", "<leader>sv", "<C-w>s", { desc = "Split window vertically" }) -- split window vertically
keymap.set("n", "<leader>sh", "<C-w>v", { desc = "Split window horizontally" }) -- split window horizontally
keymap.set("n", "<leader>se", "<C-w>=", { desc = "Make splits equal size" }) -- make split windows equal width & height
keymap.set("n", "<leader>sx", "<cmd>close<CR>", { desc = "Close current split" }) -- close current split window
keymap.set("n", "<leader>ss", "<C-x>", { desc = "Swap current window with next" }) -- swap window with next

-- WINDOW Navigation
keymap.set("n", "<leader>nk", "<C-w>k", { desc = "Window - Move up" }) -- window nav - move up
keymap.set("n", "<leader>nj", "<C-w>j", { desc = "Window - Move down" }) -- window nav - move down
keymap.set("n", "<leader>nh", "<C-w>h", { desc = "Window - Move left" }) -- window nav - move left
keymap.set("n", "<leader>nl", "<C-w>l", { desc = "Window - Move right" }) -- window nav - move right

-- Copilot
keymap.set("n", "<leader>Ct", function() require("CopilotChat").toggle() end, { desc = "Copilot - Toggle" })
keymap.set("n", "<leader>Cq", function() require("CopilotChat").ask(input, { selection = require("CopilotChat.select").buffer }) end, { desc = "Copilot - Quick Chat" })

keymap.set('n', "<leader>nm", function() require('nvim-window').pick() end, {desc = "nvim-window: Jump to window"})

-- Tab management / BarBar.nvim (Tab based buffer management and navigation)
keymap.set('n', '<leader>th', '<Cmd>BufferPrevious<CR>', {desc = "Go to previous buffer"})
keymap.set('n', '<leader>tl', '<Cmd>BufferNext<CR>', {desc = "Go to next buffer"})
keymap.set('n', '<leader>tc', '<Cmd>BufferClose<CR>', {desc = "Close buffer"})
keymap.set('n', '<leader>tp', '<Cmd>BufferPick<CR>', {desc = "Pick buffer"})
keymap.set('n', '<leader>tn', '<cmd>tabnew<CR>', {desc = "New tab"})

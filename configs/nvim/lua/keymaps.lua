-- File for keymap settings and overrides
local keymap = vim.keymap

-- Nvim-tree
keymap.set('n', '<C-n>', ':NvimTreeFocus<CR>')

-- LazyGit
keymap.set('n', '<leader>lg', '<cmd>LazyGit<cr>', {desc = "LazyGit"})

-- Telescope
-- <cmd> strings (rather than require('telescope.builtin')) keep these
-- lazy-safe: the :Telescope command loads the plugin on first use.
keymap.set('n', '<C-p>', '<cmd>Telescope find_files<cr>', { desc = "Telescope - Find files" })
keymap.set('n', '<leader>ff', '<cmd>Telescope find_files<cr>', { desc = "Find files" })
keymap.set('n', '<leader>fg', '<cmd>Telescope live_grep<cr>', { desc = "Live grep (ripgrep)" })
keymap.set('n', '<leader>fb', '<cmd>Telescope buffers<cr>', { desc = "Find open buffers" })
keymap.set('n', '<leader>fo', '<cmd>Telescope oldfiles<cr>', { desc = "Recently opened files" })
keymap.set('n', '<leader>fw', '<cmd>Telescope grep_string<cr>', { desc = "Grep word under cursor" })
keymap.set('n', '<leader>fh', '<cmd>Telescope help_tags<cr>', { desc = "Search help tags" })
keymap.set('n', '<leader>fd', '<cmd>Telescope diagnostics<cr>', { desc = "Search diagnostics" })
keymap.set('n', '<leader>fk', '<cmd>Telescope keymaps<cr>', { desc = "Search keymaps" })
keymap.set('n', '<leader>fr', '<cmd>Telescope resume<cr>', { desc = "Resume last picker" })
keymap.set('n', '<leader>f/', '<cmd>Telescope current_buffer_fuzzy_find<cr>', { desc = "Fuzzy find in buffer" })

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

keymap.set('n', "<leader>nm", function() require('nvim-window').pick() end, {desc = "nvim-window: Jump to window"})

-- Obsidian (notes vault). Uses the `Obsidian <subcommand>` form; the older
-- ObsidianXxx commands are deprecated and removed in 4.0.
-- Inside a note the plugin also provides <CR> (follow link / toggle checkbox)
-- and ]o / [o on its own, buffer-locally.
keymap.set('n', '<leader>ms', '<cmd>Obsidian search<cr>', { desc = "Search vault contents" })
keymap.set('n', '<leader>mq', '<cmd>Obsidian quick_switch<cr>', { desc = "Quick switch note" })
keymap.set('n', '<leader>mt', '<cmd>Obsidian tags<cr>', { desc = "Find notes by tag" })
keymap.set('n', '<leader>mn', '<cmd>Obsidian new<cr>', { desc = "New note" })
keymap.set('n', '<leader>md', '<cmd>Obsidian today<cr>', { desc = "Today's daily note" })
keymap.set('n', '<leader>mD', '<cmd>Obsidian dailies<cr>', { desc = "Browse daily notes" })
keymap.set('n', '<leader>mw', '<cmd>Obsidian workspace<cr>', { desc = "Switch vault" })
-- These need to be run from inside a note
keymap.set('n', '<leader>mb', '<cmd>Obsidian backlinks<cr>', { desc = "Backlinks to this note" })
keymap.set('n', '<leader>mr', '<cmd>Obsidian rename<cr>', { desc = "Rename note, rewrite links" })
keymap.set('n', '<leader>mo', '<cmd>Obsidian open<cr>', { desc = "Open note in Obsidian app" })
keymap.set('n', '<leader>mp', '<cmd>Obsidian paste_img<cr>', { desc = "Paste image as attachment" })
keymap.set('n', '<leader>mc', '<cmd>Obsidian toggle_checkbox<cr>', { desc = "Toggle checkbox" })
keymap.set('n', '<leader>mL', '<cmd>Obsidian links<cr>', { desc = "List links in note" })
keymap.set('n', '<leader>mT', '<cmd>Obsidian toc<cr>', { desc = "Table of contents" })
-- Visual mode: these subcommands accept a range
keymap.set('v', '<leader>ml', ':Obsidian link<cr>', { desc = "Link selection to a note" })
keymap.set('v', '<leader>mL', ':Obsidian link_new<cr>', { desc = "Link selection to a new note" })
keymap.set('v', '<leader>me', ':Obsidian extract_note<cr>', { desc = "Extract selection to new note" })

-- Diffview (git diffs and file history)
-- <cmd> strings keep these lazy-safe; the commands load the plugin on demand.
keymap.set('n', '<leader>gd', '<cmd>DiffviewOpen<cr>', { desc = "Diff working tree vs HEAD" })
keymap.set('n', '<leader>gc', '<cmd>DiffviewClose<cr>', { desc = "Close diffview" })
keymap.set('n', '<leader>gf', '<cmd>DiffviewFileHistory %<cr>', { desc = "History of current file" })
keymap.set('n', '<leader>gh', '<cmd>DiffviewFileHistory<cr>', { desc = "History of whole repo" })
keymap.set('n', '<leader>gt', '<cmd>DiffviewToggleFiles<cr>', { desc = "Toggle file panel" })
keymap.set('n', '<leader>gF', '<cmd>DiffviewFocusFiles<cr>', { desc = "Focus file panel" })
keymap.set('n', '<leader>gr', '<cmd>DiffviewRefresh<cr>', { desc = "Refresh diffview" })
-- Visual mode: ':' inserts the '<,'> range itself, and DiffviewFileHistory
-- accepts a range, so this gives history for just the selected lines.
keymap.set('v', '<leader>gf', ':DiffviewFileHistory<cr>', { desc = "History of selected lines" })

-- Tab management / BarBar.nvim (Tab based buffer management and navigation)
keymap.set('n', '<leader>th', '<Cmd>BufferPrevious<CR>', {desc = "Go to previous buffer"})
keymap.set('n', '<leader>tl', '<Cmd>BufferNext<CR>', {desc = "Go to next buffer"})
keymap.set('n', '<leader>tc', '<Cmd>BufferClose<CR>', {desc = "Close buffer"})
keymap.set('n', '<leader>tp', '<Cmd>BufferPick<CR>', {desc = "Pick buffer"})
keymap.set('n', '<leader>tn', '<cmd>tabnew<CR>', {desc = "New tab"})

-- Key mapping to close all buffers except the current one, skipping nvim-tree
vim.keymap.set("n", "<leader>wx", function()
  local current_buf = vim.api.nvim_get_current_buf()
  local buffers = vim.api.nvim_list_bufs()
  local plugin = require("lazy.core.config").plugins["colorful-winsep.nvim"]
  local nvim_tree_api = require("nvim-tree.api")
  nvim_tree_api.tree.open()

  for _, buf in ipairs(buffers) do
    if buf ~= current_buf and vim.api.nvim_buf_is_loaded(buf) then
      -- Get the buffer name
      local buf_name = vim.api.nvim_buf_get_name(buf)
      -- Debugging: Print the buffer number and name
      -- print("Buffer:", buf, "Name:", buf_name)

      -- Skip buffers with 'NvimTree' in their name
      if not buf_name:match("NvimTree") then
        print("Deleting buffer:", buf)
        vim.api.nvim_buf_delete(buf, { force = true })
      else
        print("Skipping nvim-tree buffer:", buf)
      end
    end
  end

  require("lazy.core.loader").reload(plugin)
end, { desc = "Close all buffers except the current one (skip nvim-tree)" })
 

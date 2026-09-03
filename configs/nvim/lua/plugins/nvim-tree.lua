-- nvim-tree.nvim plugin
--
-- File tree explorer
-- Link: https://github.com/nvim-tree/nvim-tree.lua
return {
  "nvim-tree/nvim-tree.lua",
  dependencies = {
    "nvim-tree/nvim-web-devicons",
    "s1n7ax/nvim-window-picker"
  },
  config = function()
    local nvimtree = require("nvim-tree")

    -- recommended settings from nvim-tree documentation
    vim.g.loaded_netrw = 1
    vim.g.loaded_netrwPlugin = 1


    -- For keymaps
    local function my_on_attach(bufnr)
      local api = require("nvim-tree.api")
      local lib = require("nvim-tree.lib")

      local function opts(desc)
        return { desc = "nvim-tree: " .. desc, buffer = bufnr, noremap = true, silent = true, nowait = true }
      end

      api.config.mappings.default_on_attach(bufnr)

      -- your removals and mappings go here
      vim.keymap.del("n", "f", { buffer = bufnr })

      -- nvim-tree binds <C-k> to its Info popup, which shadows the global
      -- <C-k> used for vim-tmux-navigator pane navigation. Drop it and move
      -- Info to "i" (free in nvim-tree's default map; only "I" is taken).
      vim.keymap.del("n", "<C-k>", { buffer = bufnr })
      vim.keymap.set("n", "i", api.node.show_info_popup, opts("Info"))

      -- remap the default keybindings
      vim.keymap.set("n", "\\", api.live_filter.start, opts("Live Filter: Start"))

      -- add custom key mapping to search in directory
      -- ...ADD KEYMAP FOR OIL HERE...
      vim.keymap.set("n", "<leader>o", function()
        --local relative_path = api.fs.copy.relative_path()
        local node = api.tree.get_node_under_cursor()
        local relative_path = ""
        if node then
          if node.type == "file" then
            relative_path = vim.fn.fnamemodify(node.absolute_path, ":h")
          else
            relative_path = node.absolute_path
            -- Expand the directory in nvim-tree
            api.node.open.edit()
          end
        end

        local oil = require("oil")
        local width = vim.o.columns
        local height = vim.o.lines
        
        oil.setup({
          float = {
            max_width = math.floor(width * 0.75),
            max_height = math.floor(height * 0.75),
          }
        })

        -- Open file tree editor with Oil in floating window
        oil.toggle_float(relative_path)
      end, opts("Open with Oil Filetree Editor"))
    end

    -- https://github.com/nvim-tree/nvim-tree.lua/blob/master/lua/nvim-tree.lua#L342
    nvimtree.setup({
      on_attach = my_on_attach,
      view = {
        width = 40,
        --relativenumber = false,
        cursorline = true,
        number = true,
        signcolumn = "yes",
      },
      sync_root_with_cwd = true,
      -- change folder arrow icons
      renderer = {
        indent_markers = {
          enable = true,
        },
        icons = {
          glyphs = {
            folder = {
              arrow_closed = "", -- arrow when folder is closed
              arrow_open = "", -- arrow when folder is open
            },
          },
        },
      },
      tab = {
        sync = {
          open = true,
          close = true,
          ignore = {},
        },
      },
      actions = {
        open_file = {
          resize_window = true,
          window_picker = {
            -- Configured in lua/plugins/nvim-windowpicker.lua
            enable = true,
          },
        },
      },
      filters = {
        custom = { ".DS_Store" },
      },
      git = {
        ignore = false,
      },
      update_focused_file = {
        enable = true,
        update_root = {
          enable = false,
          ignore_list = {},
        },
        exclude = false,
      },
    })
  end,
}

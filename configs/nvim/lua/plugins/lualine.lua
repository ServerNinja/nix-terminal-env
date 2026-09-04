-- lualine.nvim plugin
--
-- A blazing fast and easy to configure neovim statusline written in pure lua.
-- Link: https://github.com/nvim-lualine/lualine.nvim
return {
  "nvim-lualine/lualine.nvim",

  config = function()
    -- Project root, shown at the bottom of the nvim-tree pane.
    --
    -- The tree is the leftmost full-height window, so its statusline lands on
    -- the screen's bottom edge -- the one row colorful-winsep's separator
    -- floats never cover (see the note on `sections` below). Useful for
    -- telling apart several terminal windows each running nvim in a different
    -- project. Truncates from the left so the project name always survives.
    local function project_root()
      local cwd = vim.fn.fnamemodify(vim.uv.cwd() or '', ':~')
      local avail = vim.api.nvim_win_get_width(0) - 4
      if avail > 1 and #cwd > avail then
        cwd = '…' .. cwd:sub(#cwd - avail + 2)
      end
      return ' ' .. cwd
    end

    -- Both sections and inactive_sections are set: the tree is usually not the
    -- focused window, so inactive_sections is what actually renders most of
    -- the time.
    local nvim_tree_root = {
      filetypes = { 'NvimTree' },
      sections = { lualine_c = { project_root } },
      inactive_sections = { lualine_c = { project_root } },
    }

    require('lualine').setup({
      options = {
        icons_enabled = true,
        -- 'auto' follows the active colorscheme, which auto-dark-mode swaps
        theme = 'auto',
        component_separators = { left = '', right = ''},
        section_separators = { left = '', right = ''},
        disabled_filetypes = {
          statusline = {},
          winbar = {},
        },
        ignore_focus = {},
        always_divide_middle = true,
        globalstatus = false,
        refresh = {
          statusline = 1000,
          tabline = 1000,
          winbar = 1000,
        }
      },
      -- No statusline content for regular windows. With laststatus = 2 a
      -- window's statusline is drawn on the row immediately below it, and
      -- that is the same row colorful-winsep.nvim covers with its horizontal
      -- separator float, so anything here is invisible on every pane except
      -- the bottom-most one. The file label lives in the winbar instead.
      --
      -- These are empty component *lists* rather than empty tables on
      -- purpose: lualine only manages &statusline at all when one of these is
      -- non-empty (lualine.lua: `next(config.sections) ~= nil or ...`), and
      -- without that the nvim_tree_root extension below never renders.
      -- All six sections must be listed explicitly: lualine fills in its
      -- defaults for any section key left out, which would leak mode/branch/
      -- progress/location back in.
      sections = {
        lualine_a = {}, lualine_b = {}, lualine_c = {},
        lualine_x = {}, lualine_y = {}, lualine_z = {},
      },
      inactive_sections = {
        lualine_a = {}, lualine_b = {}, lualine_c = {},
        lualine_x = {}, lualine_y = {}, lualine_z = {},
      },
      tabline = {
      },
      -- Winbar: the top row of each pane, which no separator float ever
      -- overlaps, so this shows up in every pane rather than just the bottom
      -- one. Minimal by design: mode, filename, cursor position.
      winbar = {
        lualine_a = {'mode'},
        lualine_b = {},
        lualine_c = {'filename'},
        lualine_x = {},
        lualine_y = {},
        lualine_z = {'location'}
      },
      inactive_winbar = {
        lualine_a = {},
        lualine_b = {},
        lualine_c = {'filename'},
        lualine_x = {},
        lualine_y = {},
        lualine_z = {}
      },
      extensions = { nvim_tree_root }
    })

    -- The 'auto' theme derives its palette from the colorscheme at setup time,
    -- which races auto-dark-mode applying that colorscheme. Losing the race
    -- leaves lualine on Neovim's built-in palette, whose inactive background
    -- is a near-white #d7d9e1 — that is the white bar on inactive panes.
    -- lualine's own ColorScheme handler just re-runs setup() with the stored
    -- config, so do exactly that once after startup, when a colorscheme is
    -- guaranteed to be in place.
    vim.api.nvim_create_autocmd('VimEnter', {
      group = vim.api.nvim_create_augroup('LualineThemeRefresh', { clear = true }),
      callback = function()
        vim.schedule(function()
          pcall(function() require('lualine').setup() end)
        end)
      end,
    })
  end
}

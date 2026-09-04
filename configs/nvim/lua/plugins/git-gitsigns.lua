-- GitSigns plugin
--
-- Git status in the sign column, plus per-hunk stage/reset/preview
-- Link: https://github.com/lewis6991/gitsigns.nvim
--
-- Notes: keymaps are buffer-local via on_attach rather than living in
-- lua/keymaps.lua (same approach as nvim-tree). Two reasons: they should only
-- exist where gitsigns is actually attached, i.e. a git-tracked buffer; and
-- ]c / [c need to fall back to Neovim's native diff navigation inside diff
-- buffers, which matters now that <leader>g opens diffview.
return {
  'lewis6991/gitsigns.nvim',
  version = 'v0.9.0',

  config = function()
    require('gitsigns').setup({
      on_attach = function(bufnr)
        local gs = require('gitsigns')

        local function map(mode, lhs, rhs, desc)
          vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, desc = 'Gitsigns: ' .. desc })
        end

        -- Hunk navigation, diff-mode aware
        map('n', ']c', function()
          if vim.wo.diff then
            vim.cmd.normal({ ']c', bang = true })
          else
            gs.nav_hunk('next')
          end
        end, 'Next hunk')

        map('n', '[c', function()
          if vim.wo.diff then
            vim.cmd.normal({ '[c', bang = true })
          else
            gs.nav_hunk('prev')
          end
        end, 'Previous hunk')

        -- Stage and reset
        map('n', '<leader>hs', gs.stage_hunk, 'Stage hunk')
        map('n', '<leader>hr', gs.reset_hunk, 'Reset hunk')
        map('v', '<leader>hs', function()
          gs.stage_hunk({ vim.fn.line('.'), vim.fn.line('v') })
        end, 'Stage selected lines')
        map('v', '<leader>hr', function()
          gs.reset_hunk({ vim.fn.line('.'), vim.fn.line('v') })
        end, 'Reset selected lines')
        map('n', '<leader>hS', gs.stage_buffer, 'Stage whole buffer')
        map('n', '<leader>hR', gs.reset_buffer, 'Reset whole buffer')
        map('n', '<leader>hu', gs.undo_stage_hunk, 'Undo stage hunk')

        -- Inspect
        map('n', '<leader>hp', gs.preview_hunk, 'Preview hunk')
        map('n', '<leader>hb', function() gs.blame_line({ full = true }) end, 'Blame line')
        map('n', '<leader>hB', gs.toggle_current_line_blame, 'Toggle inline blame')
        map('n', '<leader>hd', gs.diffthis, 'Diff against index')
        map('n', '<leader>hD', function() gs.diffthis('~') end, 'Diff against last commit')
        map('n', '<leader>hx', gs.toggle_deleted, 'Toggle deleted lines')

        -- Text object, so `dih` / `vih` operate on the hunk under the cursor
        map({ 'o', 'x' }, 'ih', ':<C-U>Gitsigns select_hunk<CR>', 'Select hunk')
      end,
    })
  end
}

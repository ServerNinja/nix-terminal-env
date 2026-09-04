-- barbar.nvim plugin
--
-- Tabline Management Plugin
-- Link: https://github.com/romgrk/barbar.nvim
return {
  'romgrk/barbar.nvim',
  dependencies = {
    'lewis6991/gitsigns.nvim', -- OPTIONAL: for git status
    'nvim-tree/nvim-web-devicons', -- OPTIONAL: for file icons
  },

  init = function() vim.g.barbar_auto_setup = false end,

  version = '^1.0.0', -- optional: only update when a new 1.x version is released

  config = function()
    require('barbar').setup({})

    -- barbar derives its highlights from the colorscheme when it sets up, and
    -- that races auto-dark-mode applying the colorscheme. Losing the race
    -- leaves barbar on Neovim's built-in defaults (near-white #e0e2ea text on
    -- grey #4f5258), so the tabline ignores the theme entirely. barbar's own
    -- ColorScheme handler does exactly the two calls below, so recompute once
    -- after startup, when a colorscheme is guaranteed to be in place.
    vim.api.nvim_create_autocmd('VimEnter', {
      group = vim.api.nvim_create_augroup('BarbarHighlightRefresh', { clear = true }),
      callback = function()
        vim.schedule(function()
          local ok_cache, cache = pcall(require, 'barbar.utils.highlight')
          local ok_hl, hl = pcall(require, 'barbar.highlight')
          if ok_cache and ok_hl then
            cache.reset_cache()
            hl.setup()
          end
        end)
      end,
    })
  end,
}

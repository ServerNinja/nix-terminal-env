-- transparent.nvim
--
-- Removes background on nvim windows and buffers
-- Link: https://github.com/xiyaowong/transparent.nvim
--
-- Notes: Below are configurations to include / exclude groups of things we don't want this to apply to. This makes lualine look like crap so I excluded it in the exclude_groups
return {
  'xiyaowong/transparent.nvim',

  config = function()
    require('transparent').setup({
      extra_groups = {
        'TelescopePrompt',
        'TelescopeResults',
        'TelescopePreview',
        'qf',
        'lsp_finder',
        'lsp_finder_preview',
        'NvimTreeNormal',
        'NormalFloat',
      },
      exclude_groups = {
        "lualine",
      },
    })
  end,
}

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
    })
  end,
}

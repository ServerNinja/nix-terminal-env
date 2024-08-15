-- hlchunk.nvim plugin
--
-- Higlight the current chunk of code and indent lines
-- Link: https://github.com/shellRaining/hlchunk.nvim
return {
  "shellRaining/hlchunk.nvim",
  event = { "BufReadPre", "BufNewFile" },
  config = function()
    require("hlchunk").setup({
      chunk = {
        enable = true,
        use_treesitter = false,
        style = {
          "#00ffff",
          "#FF0000",
        },
        duration = 100, -- miliseconds
        delay = 150, -- miliseconds
      },
      indent = {
        enable = true,
        chars = {
            "│",
        },
      },
      line_num = {
        enable = false, -- Disable highlighting line numbers
        style = {
          "#FF0000",
        },
      },
    })
  end
}

-- peek.nvim plugin
--
-- Markdown preview in a browser window (requires Deno)
-- Link: https://github.com/toppair/peek.nvim
return {
  "toppair/peek.nvim",
  ft = { "markdown" },
  build = "deno task --quiet build:fast",
  config = function()
    require("peek").setup({
      auto_load = false,
      close_on_bdelete = true,
      syntax = true,
      theme = "dark",
      update_on_change = true,
    })
    vim.api.nvim_create_user_command("PeekOpen", require("peek").open, {})
    vim.api.nvim_create_user_command("PeekClose", require("peek").close, {})
  end,
}

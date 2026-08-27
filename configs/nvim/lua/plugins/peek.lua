-- peek.nvim plugin
--
-- Markdown preview in a browser window (requires Deno)
-- Link: https://github.com/toppair/peek.nvim
return {
  "toppair/peek.nvim",
  ft = { "markdown" },
  build = "deno task --quiet build:fast",
  keys = {
    { "<leader>cg", "<cmd>PeekOpen<cr>",  desc = "Peek - Open preview" },
    { "<leader>cG", "<cmd>PeekClose<cr>", desc = "Peek - Close preview" },
  },
  config = function()
    local is_linux = vim.uv.os_uname().sysname == "Linux"

    require("peek").setup({
      auto_load = false,
      close_on_bdelete = true,
      syntax = true,
      theme = "dark",
      update_on_change = true,
      -- The native webview works on macOS, but exits immediately on this
      -- Linux system; use the default browser there instead.
      app = is_linux and "browser" or "webview",
    })
    vim.api.nvim_create_user_command("PeekOpen", require("peek").open, {})
    vim.api.nvim_create_user_command("PeekClose", require("peek").close, {})
  end,
}

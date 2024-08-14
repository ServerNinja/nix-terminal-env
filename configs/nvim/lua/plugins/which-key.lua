return {
  "folke/which-key.nvim",
  event = "VeryLazy",
  opts = {
    -- This isn't working for some reason --- ? WTF
    win = {
--      no_overlap = true,
      border = "single",
      padding = { 1, 2 },
      title = true,
      title_pos = "center",
      zindex = 1000,
    },
  },
  config = function(_, opts)
    local wk = require("which-key")
    -- As an example, we will create the following mappings:
    --  * <leader>ff find files
    --  * <leader>fr show recent files
    --  * <leader>fb Foobar
    -- we'll document:
    --  * <leader>fn new file
    --  * <leader>fe edit file
    -- -- and hide <leader>1
   
    wk.add({
    -- group renames
      { "<leader>C", group = "Copilot Chat" },
      { "<leader>l", group = "Lazy"},
      { "<leader>n", group = "Window Navigation", icon = { icon = "", color = "azure" } },
      { "<leader>s", group = "Split", icon = { icon = "", color = "purple" } },
      { "<leader>t", group = "Tab Management", icon = { icon = "", color = "green" } },
      { "<leader>w", group = "Window Management", icon = { icon = "", color = "azure" } },
    }, { prefix = "<leader>" })
    wk.setup(opts)
  end,
  keys = {
    {
      "<leader>?",
      function()
        require("which-key").show({ global = false })
      end,
      desc = "Buffer Local Keymaps (which-key)",
    },
  },
}

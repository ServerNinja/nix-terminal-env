-- nvim-treesitter plugin
--
-- For syntax highlighting and indentation
-- Works with the tree-sitter interface in Neovim
--
-- Link: https://github.com/nvim-treesitter/nvim-treesitter
return { 
  "nvim-treesitter/nvim-treesitter", 
  build = ":TSUpdate",

  config = function()
    local treesitter_config = require("nvim-treesitter.configs")
    treesitter_config.setup({
      ensure_installed = {"lua", "javascript", "c", "rust", "java", "python", "bash", "hcl", "terraform"},
      highlight = { enable = true },
      indent = { enable = true},
    })
  end
}

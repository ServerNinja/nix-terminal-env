-- obsidian.nvim plugin
--
-- Edit an Obsidian vault from Neovim: [[wiki link]] following and completion,
-- backlinks, tag/note search, and note renaming that rewrites every inbound
-- link.
-- Link: https://github.com/obsidian-nvim/obsidian.nvim
--
-- Notes: this is the community fork, which is where development moved. The
-- original epwalsh/obsidian.nvim has been stale since 2026-04.
--
-- Keymaps live in lua/keymaps.lua under the <leader>m prefix.

-- Vault paths differ per machine, so only offer the ones that exist on this
-- one. On a box with no vaults the plugin installs but never activates.
--
-- A vault deliberately keeps the same name on every machine even though its
-- path differs, so `:Obsidian workspace main` means the same thing anywhere.
-- Duplicate names are safe because only one path per name ever exists on a
-- given box; if both did, obsidian.nvim would take the first match.
local function workspaces()
  local candidates = {
    { name = 'spirituality', path = '~/Documents/Obsidian-Spirituality/Spirituality' },
    { name = 'spirituality', path = '~/Documents/ObsidianVaultSpirituality/Spirituality' },
    { name = 'main',         path = '~/Documents/Obsidian' },
    { name = 'main',         path = '~/Documents/ObsidianVault/ServerNinja' },
    { name = 'testing',      path = '~/Documents/Obsidian-Testing/Testing' },
  }
  local found = {}
  for _, c in ipairs(candidates) do
    if vim.fn.isdirectory(vim.fn.expand(c.path)) == 1 then
      table.insert(found, c)
    end
  end
  return found
end

return {
  'obsidian-nvim/obsidian.nvim',
  version = '*',
  cond = function() return #workspaces() > 0 end,

  -- Load when a note in a vault is opened, so link following and [[
  -- completion are live while editing. The commands also load it on demand.
  event = {
    'BufReadPre  ' .. vim.fn.expand('~') .. '/Documents/Obsidian*/**/*.md',
    'BufNewFile  ' .. vim.fn.expand('~') .. '/Documents/Obsidian*/**/*.md',
  },

  dependencies = {
    'nvim-lua/plenary.nvim',
    'nvim-telescope/telescope.nvim',
  },

  opts = function()
    return {
      workspaces = workspaces(),
      -- Matches .obsidian/app.json's attachmentFolderPath = ./attachments
      attachments = { folder = 'attachments' },
      picker = { name = 'telescope.nvim' },
      -- Use the `Obsidian <subcommand>` form only. The old ObsidianXxx
      -- commands still exist but warn on every load and go away in 4.0.
      legacy_commands = false,
      -- Leave link/checkbox concealment off: this config deliberately stops
      -- the markdown Tree-sitter highlighter (see after/ftplugin/markdown.lua)
      -- and uses vim-markdown's regex syntax instead.
      ui = { enable = false },
      -- Left at defaults. Tag completion needs two characters after the `#`
      -- (`#al`, not `#a`); setting completion.min_chars = 1 does not change
      -- that, because the tag search applies its own two-character floor.
      -- No nvim_cmp key here: [[ completion is served by the plugin's
      -- built-in obsidian-ls LSP server, which is why nvim-cmp.lua needs the
      -- cmp-nvim-lsp dependency for the `nvim_lsp` source to exist at all.
    }
  end,
}

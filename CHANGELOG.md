# Changelog

All notable changes to this environment are recorded here. The current version
is in [`VERSION`](VERSION).

Format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).
Versioning is [SemVer](https://semver.org/) applied to the environment as a
whole: **major** for changes needing manual migration on each machine,
**minor** for new tools or configs, **patch** for fixes that apply cleanly.

## [Unreleased]

### Fixed

- Deleting a line in an Obsidian note left ghost rows on screen until a
  manual redraw. obsidian.nvim's **footer** (`{{backlinks}} {{properties}}
  {{words}} {{chars}}`, on by default) draws `virt_lines` below the last
  line — two of them, since `separator` defaults to an 80-dash rule — and
  Neovim does not reliably invalidate that region when the buffer shrinks.
  Using vim-markdown's regex syntax instead of Tree-sitter makes it worse,
  because regex redraw is line-based and never touches the area below the
  last line. Set `footer = { enabled = false }`.

  Note `ui = { enable = false }` does **not** cover the footer; it is gated
  separately. Disabling it also stops `b:obsidian_status` updating, so the
  `statusline` option is inert — the footer module is the only thing that
  starts it. Backlinks are still available on demand via `<leader>mb`.

- obsidian.nvim did not load when opening a note in the **vault root**
  (e.g. `~/Documents/Obsidian/README.md`). The lazy-load glob used only
  `Obsidian*/**/*.md`, and `/**/` requires at least one intervening
  directory, so root-level notes never matched and got no link following or
  `[[` completion. Added the `Obsidian*/*.md` form alongside it.

- obsidian.nvim's `<leader>m` keymaps that *find* a note (`ms` search, `mq`
  quick-switch, `mt` tags, `mn` new, `md`/`mD` dailies, `mw` workspace) failed
  with `E492: Not an editor command: Obsidian` from a cold start. The spec
  lazy-loaded only on opening a file inside a vault, so the maps meant to get
  you *into* a vault ran before the plugin — and its command — existed. Added
  `cmd = 'Obsidian'` so first use of the command loads it. The in-note maps
  (backlinks, rename, toc) were never affected, which is why this hid for a
  while.

- obsidian.nvim showed as **disabled** in `:Lazy` on Linux machines. The
  workspace list only held the macOS vault paths, and the spec is
  `cond`-gated on at least one existing — so with no match the plugin
  installed but never activated. Added the Linux vault paths
  (`~/Documents/ObsidianVault/ServerNinja` and
  `~/Documents/ObsidianVaultSpirituality/Spirituality`) alongside them.
  Candidates that don't exist stay inert, so one list serves every machine.

  A vault keeps the **same workspace name** on every machine even though its
  path differs, so `:Obsidian workspace main` means the same thing anywhere.

  Manual step: **fully restart Neovim** on the Linux box — `cond` is
  evaluated once while lazy.nvim builds its plugin list at startup, so an
  already-open session keeps reporting the plugin as disabled no matter what
  the file says. No `:Lazy` action needed; the plugin was already installed
  at the locked version.

## [1.2.0] - 2026-09-04

### Added

- obsidian.nvim (the maintained `obsidian-nvim/` fork — the original
  `epwalsh/` repo has been stale since 2026-04), for editing the Obsidian
  vaults from Neovim. Keymaps under `<leader>m`:

  | Key | Action |
  |-----|--------|
  | `<leader>ms` / `<leader>mq` | Search vault contents / quick-switch note |
  | `<leader>mt` | Find notes by tag |
  | `<leader>mn` | New note |
  | `<leader>md` / `<leader>mD` | Today's daily note / browse dailies |
  | `<leader>mw` | Switch vault |
  | `<leader>mb` | Backlinks to this note |
  | `<leader>mr` | Rename note, rewriting every inbound link |
  | `<leader>mo` / `<leader>mp` | Open in the Obsidian app / paste image attachment |
  | `<leader>mc` | Toggle checkbox |
  | `<leader>mL` / `<leader>mT` | List links / table of contents |
  | `<leader>ml`, `<leader>mL`, `<leader>me` (visual) | Link selection, link to new note, extract to new note |

  Inside a note the plugin adds its own buffer-local `<CR>` (follow link or
  toggle checkbox) and `]o`/`[o`, so those are left alone.

  Vault paths are macOS-specific, so the workspace list is built from
  directories that exist and the spec is `cond`-gated on finding at least
  one — on a machine with no vaults it installs but never activates.

  `[[` completion is served by the plugin's built-in `obsidian-ls` LSP
  server, which gives the `nvim_lsp` source already listed in `nvim-cmp.lua`
  something to talk to for the first time. `ui.enable = false` because this
  config deliberately stops the markdown Tree-sitter highlighter.
- Gitsigns keymaps, which the plugin also lacked entirely — it was drawing
  signs in the gutter and nothing more. Under a `<leader>h` (hunks) group,
  plus diff-mode-aware hunk navigation and a hunk text object:

  | Key | Action |
  |-----|--------|
  | `]c` / `[c` | Next / previous hunk (falls back to native diff nav in diff buffers) |
  | `<leader>hs` / `<leader>hr` | Stage / reset hunk (visual mode: selected lines) |
  | `<leader>hS` / `<leader>hR` | Stage / reset whole buffer |
  | `<leader>hu` | Undo stage hunk |
  | `<leader>hp` | Preview hunk |
  | `<leader>hb` / `<leader>hB` | Blame line / toggle inline blame |
  | `<leader>hd` / `<leader>hD` | Diff against index / last commit |
  | `<leader>hx` | Toggle deleted lines |
  | `ih` | Hunk text object, so `dih` / `vih` work |

  These are buffer-local via `on_attach`, not global in `lua/keymaps.lua`, so
  they only exist in git-tracked buffers and `]c`/`[c` can defer to Neovim's
  native diff navigation inside diffview.
- Diffview keymaps under a `<leader>g` group, since the plugin previously had
  none and was only reachable by typing `:Diffview…` commands:

  | Key | Action |
  |-----|--------|
  | `<leader>gd` | Diff working tree vs HEAD |
  | `<leader>gc` | Close diffview |
  | `<leader>gf` | History of current file (visual mode: selected lines) |
  | `<leader>gh` | History of whole repo |
  | `<leader>gt` | Toggle file panel |
  | `<leader>gF` | Focus file panel |
  | `<leader>gr` | Refresh |

  diffview.nvim now lazy-loads on its commands rather than at startup.
- The project root is now shown at the bottom of the nvim-tree pane, via a
  lualine extension scoped to the `NvimTree` filetype. The tree is the
  leftmost full-height window, so its statusline lands on the screen's bottom
  edge — the one row colorful-winsep's separator floats never cover. Makes it
  possible to tell apart several terminal windows each running nvim in a
  different project. The path is shown `:~`-relative and truncated from the
  left (`…/Obsidian-Spirituality/Spirituality`) so the project name always
  survives in the 40-column tree.

### Changed

- Cut the per-pane file label back to mode, filename and cursor position, and
  kept it in the winbar (the top row of each pane). `branch`, `diff` and
  `diagnostics` on the left plus `encoding`, `fileformat` and `filetype` on
  the right were squeezing the filename out of view in narrow splits.

  The statusline is now explicitly empty, because it cannot be used here:
  with `laststatus = 2` a window's statusline is drawn on the row immediately
  below it, and colorful-winsep.nvim covers exactly that row with its
  horizontal separator float. Measured in a stacked split — upper pane
  occupies rows 1-37, so its statusline is row 38, and the separator float is
  a 133-column-wide window at row 38. Only the bottom-most pane escapes,
  since its statusline sits at the screen edge where no separator is drawn.
  That is why a bottom label appeared on just one pane. Winbar rows (1 and
  39 in the same layout) are never overlapped, so the label shows on every
  pane in both stacked and side-by-side splits.

  This also drops the pending-plugin-updates indicator that lived in the
  winbar, so `:Lazy check` is now the only place available updates surface.

### Fixed

- LSP completion could never work: `nvim-cmp.lua` configured a
  `{ name = "nvim_lsp" }` source but `hrsh7th/cmp-nvim-lsp`, the plugin that
  registers that source, was never in the dependency list — and nvim-cmp
  silently drops sources it does not know. Found while wiring up
  obsidian.nvim's `#` tag completion, which is served over LSP and so was
  producing nothing. Adding the dependency also means real language servers
  will work with no further wiring whenever they get added.
- **Regression from 1.0.0**: inactive panes showed a near-white winbar.
  Changing lualine to `theme = 'auto'` in 1.0.0 made its palette derive from
  the colorscheme at setup time, which races auto-dark-mode applying that
  colorscheme. Losing the race left lualine on Neovim's built-in palette,
  where `lualine_c_inactive` is `#888a91` on `#d7d9e1` — a white bar under
  every inactive split. The previous hardcoded `dracula` theme was a fixed
  palette and so was immune. lualine's own ColorScheme handler re-runs
  `setup()` with the stored config, so that now runs once on `VimEnter`.
  `lualine_c_inactive` is `#6c7086` on `#181825` again.
- barbar's tabline ignored the colorscheme, rendering near-white text on grey
  (Neovim's built-in defaults: `#e0e2ea` on `#4f5258`) instead of catppuccin.
  barbar derives its highlights from the colorscheme when it sets up, and
  nothing applied a colorscheme at startup — auto-dark-mode does it out of
  band, after barbar has already computed. barbar's `ColorScheme` handler did
  not recover it. Its two recompute calls (`utils.highlight.reset_cache()` and
  `highlight.setup()`) now run once on `VimEnter`, after a colorscheme is
  guaranteed to be in place. Inactive buffers now match `TabLine` exactly.

### Upgrading to 1.2.0

```sh
git pull && ./setup.sh
```

`setup.sh` installs the two new plugins from the updated `lazy-lock.json`
(obsidian.nvim and cmp-nvim-lsp), then restart Neovim. Notes:

- The Obsidian vault paths are macOS-specific. On a machine without them the
  plugin installs but stays dormant, so nothing needs configuring there. To
  use it elsewhere, add that machine's vault path to the candidate list in
  `lua/plugins/obsidian.lua`.
- Tag completion needs two characters after the `#` (`#al`, not `#a`).
- New leader groups: `<leader>g` git diffs, `<leader>h` git hunks,
  `<leader>m` Obsidian notes. `<leader>?` lists what is available in the
  current buffer.

## [1.1.0] - 2026-09-03

### Fixed

- Plain `vim` never shared the system clipboard. `configs/vim/vimrc` set
  `clipboard=unnamedplus`, but that flag uses the `+` register, which needs
  the `+X11` or `+wayland_clipboard` feature; macOS vim has `+clipboard` and
  no X11, so the setting silently did nothing and only `*` was ever wired to
  the pasteboard. The vimrc now branches on `has('unnamedplus')`:
  `unnamedplus,unnamed` on X11/Wayland, `unnamed` on macOS. Neovim was never
  affected because it uses a clipboard provider (`pbcopy`/`pbpaste`) rather
  than X11, which is why it worked and vim did not.
- `<C-k>` did not navigate panes while the cursor was in the nvim-tree
  window. nvim-tree binds `<C-k>` buffer-locally to its Info popup, which
  shadowed the global vim-tmux-navigator mapping. The tree's `<C-k>` is now
  deleted in `on_attach` and Info moved to `i`. `<C-h>`, `<C-j>` and `<C-l>`
  were never affected — `<C-k>` is the only one nvim-tree claims.
- No completion popup when typing `:` in Neovim. nvim-cmp was gated on
  `event = "InsertEnter"` only, so entering the cmdline never loaded the
  plugin and the `cmp.setup.cmdline(":")` / `("/")` blocks in its config
  never ran. The trigger is now `{ "InsertEnter", "CmdlineEnter" }`.

### Upgrading to 1.1.0

```sh
git pull && ./setup.sh
```

No plugin versions changed, so `lazy-lock.json` is untouched — this is config
only. Two caveats:

- Restart Neovim for the nvim-cmp and nvim-tree keymap changes to take effect.
- On Debian, plain `vim` may still not reach the clipboard after this. The
  default `vim` package is commonly built without clipboard support, which no
  setting can work around. Check with:

  ```sh
  vim --version | grep -o '[+-]clipboard'
  ```

  A `-clipboard` build needs a different package; `vim-gtk3` provides one with
  `+clipboard` and `+X11`. Neovim is unaffected either way.

## [1.0.0] - 2026-09-03

First tracked version. Baselines the environment across macOS and Linux and
removes ~16 months of plugin drift.

### Added

- `VERSION` and this changelog. `setup.sh` logs the version it is applying.
- `AGENTS.md`, with `CLAUDE.md` symlinked to it, documenting repo conventions
  for AI coding agents (Codex, Cursor, Claude Code).
- `tfswitch` (Terraform/OpenTofu version switcher) installed on both macOS and
  Linux via the official script, gated by `SETUP_TFSWITCH`.
- `SETUP_NVIM_SYNC` toggle: `setup.sh` now converges Neovim plugins to
  `lazy-lock.json` so every machine runs identical versions.
- A `<leader>c` which-key group title, "Markdown Preview", for the peek.nvim
  bindings (`cg` open, `cG` close) that previously showed up untitled.
- Telescope keymaps under a `<leader>f` group: `ff` files, `fg` live grep,
  `fb` buffers, `fo` recent, `fw` word under cursor, `fh` help, `fd`
  diagnostics, `fk` keymaps, `fr` resume last picker, `f/` fuzzy-find in
  buffer. `<C-p>` still opens find_files. Telescope now lazy-loads on the
  `:Telescope` command instead of at startup.
- tmux splits inherit the current pane's working directory.

### Changed

- **`configs/nvim/lazy-lock.json` is now tracked in git.** Plugin versions are
  shared across machines instead of resolved per machine. Updating plugins is
  now a deliberate act: `:Lazy update`, verify, then commit the lockfile.
- lazy.nvim update checking is on (it was effectively invisible before, which
  is why plugin updates went unnoticed for over a year), but reports quietly:
  `checker.notify = false` with `frequency = 86400`, and the pending-update
  count renders in the lualine winbar via `lazy.status`. `notify = true` prints
  every pending plugin on startup and blocks on a hit-enter prompt — unusable
  while updates are deliberately deferred. Use `:Lazy check` for detail.
- which-key sorts entries alphanumerically: `sort = { "order", "alphanum",
  "mod" }`. The default includes `"group"` (forces groups to the end of the
  list) and `"local"` (hoists buffer-local mappings such as `<leader>o` for
  Oil), both of which broke key order.
- lualine `theme` is `auto`, so the statusline follows the colorscheme that
  auto-dark-mode selects rather than always rendering `dracula`.
- window-picker's configuration lives only in
  `lua/plugins/nvim-windowpicker.lua`. `nvim-tree` was calling `setup()` on it
  a second time with different options.
- colorful-winsep is pinned to `branch = "main"`.
- `zsh`: `ls` falls back to `/bin/ls` when given a file path, since `nerd-ls`
  only handles directories.

### Removed

- **GitHub Copilot**: `copilot.lua` and `CopilotChat.nvim` specs, their
  keymaps (`<leader>Ct`, `<leader>Cq`), the `<leader>C` which-key group, the
  `copilot_assume_mapped` global, and the Copilot entries in the nvim-cmp
  sources and lspkind `symbol_map`. Subscription cancelled; any future use will
  be CLI-based rather than in-editor.
- **rustaceanvim** (the `RustLsp` command) and its `nvim-dap` dependency, plus
  the `<leader>a` code-action keymap. The spec had declared its dependency with
  `require = {...}`, which is not a lazy.nvim key, so `nvim-dap` was never
  actually installed and Rust debugging had never worked. The Tree-sitter
  `rust` parser is kept, so Rust syntax highlighting is unaffected.
- Eight orphaned plugin directories that were on disk but in no spec:
  `aerial.nvim`, `focus.nvim`, `mini.nvim`, `shade.nvim`, `themery.nvim`,
  `vim-fugitive`, `vim-terraform`, and a `vim-fugitive.nvim.cloning` artifact
  from a failed clone.

### Fixed

- colorful-winsep set `config` twice in one table; the first (`config = true`)
  was dead. It was also stuck on the upstream `alpha` branch, which no longer
  exists — `:Lazy update` failed on it.
- Deprecated APIs: `vim.loop` → `vim.uv` (`init.lua`) and
  `vim.api.nvim_get_option` → `vim.o` (`nvim-tree.lua`).
- The telescope spec's `config` function assigned an unused local and never
  called `setup()`.
- Removed a commented-out nvim-tree `picker` block referencing a local that no
  longer exists.
- `clone_or_update` in `setup.sh` failed permanently once an upstream renamed
  its default branch. `figlet-fonts` moved `master` -> `main`, so every run
  logged *"specifies to merge with the ref 'refs/heads/master' ... no such ref
  was fetched"*. It now detects the remote's current default branch and
  re-points the local clone, skipping any checkout that has local edits.

### Upgrading to 1.0.0

Run these on **each machine** (macOS and Linux alike). Steps 2–3 are what
`setup.sh` automates.

1. **Upgrade Neovim.** Several deferred plugin updates require 0.12:

   ```sh
   brew upgrade neovim   # 0.11.x -> 0.12.x, both platforms
   nvim --version        # confirm >= 0.12.0
   ```

2. **Pull and apply the repo:**

   ```sh
   git pull
   ./setup.sh            # symlinks, then Lazy clean + install + restore
   ```

   To do step 2 by hand instead, open `nvim` and run `:Lazy clean` (drop
   removed plugins), then `:Lazy restore` (check out the locked commits).

   On first run each machine logs `figlet-fonts: upstream default branch is now
   'main'` once while the clone is re-pointed. That is expected, not an error.

3. **Verify:**

   ```sh
   nvim --headless "+checkhealth" +qa    # or :checkhealth inside nvim
   ```

   Expect no errors from `lazy` or `nvim-treesitter`. Copilot and rustaceanvim
   should no longer appear at all.

4. **Re-test Markdown highlighting.** `init.lua` monkeypatches
   `vim.treesitter.start` and `after/ftplugin/markdown.lua` calls
   `vim.treesitter.stop()` to dodge a Tree-sitter Markdown crash observed on
   Neovim 0.12. Open a `.md` file after upgrading; if highlighting is fine
   without the workaround, that patch can be removed.

### Deferred

Known-available updates intentionally **not** taken here, to keep this release
free of plugin-version risk. Each needs its own migration:

| Item | Current | Available | Blocker |
|------|---------|-----------|---------|
| nvim-treesitter | v0.9.2 (`master`) | `main` rewrite | Needs nvim 0.12 + `tree-sitter-cli`; upstream calls it "a full, incompatible rewrite". `master` is frozen. |
| telescope.nvim | 0.1.8 (hard-pinned) | v0.2.2 | Requires nvim >= 0.11.7 |
| gitsigns.nvim | v0.9.0 (hard-pinned) | v2.1.0 | Two major versions |
| catppuccin | v1.8.0 | v2.0.0 | Major |
| nvim-tree.lua | v1.5 | v1.18.0 | Many minors |
| window-picker | v2.0.3 | v2.4.0 | `other_win_hl_color` is replaced by a `highlights` table |
| peek.nvim | current | — | Upstream dormant since 2024-04; replacement worth evaluating |

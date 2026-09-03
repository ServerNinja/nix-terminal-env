# Changelog

All notable changes to this environment are recorded here. The current version
is in [`VERSION`](VERSION).

Format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).
Versioning is [SemVer](https://semver.org/) applied to the environment as a
whole: **major** for changes needing manual migration on each machine,
**minor** for new tools or configs, **patch** for fixes that apply cleanly.

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

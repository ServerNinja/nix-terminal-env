# Agent Notes

Dotfiles repo. `setup.sh` symlinks `configs/*` into `$HOME`. See README.md for
the config inventory and install steps — don't duplicate those here.

## Gotchas that bite

**Overrides are copied, not symlinked.** `~/.zsh_config_overrides` and
`~/.wezterm_overrides.lua` are `cp`'d on first run only. Editing
`configs/zsh/zsh_config_overrides` does **not** affect this machine — those repo
files are templates for *new* machines. Edit `$HOME` directly for local tweaks.
Everything else in `configs/` is symlinked, so repo edits are live edits.

**Config edits need an explicit reload.** A file change alone does nothing:
- tmux → `tmux source-file ~/.tmux.conf` (or `C-a r`)
- zsh → `source ~/.zshrc`
- nvim → restart, or `:Lazy sync` after plugin spec changes

**Everything must work on macOS, Debian desktop, and headless Linux servers.**
Both platforms use Homebrew (`Brewfile.osx` / `Brewfile.linux`), but they are
not interchangeable: **casks are macOS-only**, so a cask-only tool cannot go in
`Brewfile.linux` — use its official install script in `setup.sh` instead. Guard
platform-specific work with `[[ "$(uname)" == "Darwin" ]]`. Don't assume a GUI.

## Adding an installed tool

Five places, or it's half-done:
1. `install_<tool>()` in `setup.sh`
2. An `is_enabled "$SETUP_<TOOL>"` gate in the Main section
3. `SETUP_<TOOL>=true` in `setup.conf.template`
4. A README section
5. A `CHANGELOG.md` entry

`setup.conf` is gitignored and never regenerated, so existing machines won't
have the new toggle — `is_enabled` treats **unset as enabled**, which is what
makes that safe. Don't add the toggle to `setup.conf` itself.

## Versioning

`VERSION` holds the environment version; `CHANGELOG.md` records what changed.
Any change that a *different machine* has to react to needs a changelog entry
under `## [Unreleased]` (create it if absent), including the manual steps
required. Bump `VERSION` when cutting a release: major if machines need manual
migration, minor for new tools/configs, patch for clean-applying fixes.

## setup.sh conventions

- Log via `log_info` / `log_warning` / `log_error`, never bare `echo` (except
  the deliberate post-install reminder block at the end).
- Reuse `link_config` (backs up real files, replaces stale symlinks) and
  `clone_or_update` (clone once, then pull) rather than raw `ln`/`git clone`.
- Every installer: early-return if the command is already on PATH, wrap
  `curl | sh` in `(set -o pipefail; ...)`, and log a manual retry command on
  failure.
- Prefer installing to `~/.local/bin` (on PATH via `zshrc`) to avoid `sudo`.
- `setup.sh` must stay idempotent — it is expected to be re-run often.

## Neovim

`configs/nvim/` uses lazy.nvim with `{ import = "plugins" }`: one file per
plugin in `configs/nvim/lua/plugins/`, each returning a spec table. Options
live in `lua/vim-options.lua`, keymaps in `lua/keymaps.lua`.
**`lazy-lock.json` is tracked in git** and is the source of truth for plugin
versions across machines. Never edit it by hand.
- To apply the repo's versions: `./setup.sh` (or `:Lazy restore`).
- To update plugins: `:Lazy update`, verify, then **commit the lockfile** in the
  same change as any spec edits it required.
- Never use `:Lazy sync` in scripts — it updates plugins, defeating the
  lockfile. `setup.sh` uses `clean` + `install` + `restore` deliberately.

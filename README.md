# nix-terminal-env

Personal terminal environment and development tool configurations, maintained
across macOS, Debian Linux desktop, and home lab Linux servers.

Current version: see [`VERSION`](VERSION). Changes and per-machine upgrade
steps are recorded in [`CHANGELOG.md`](CHANGELOG.md).

## What's Included

| Config | Managed file(s) |
|--------|----------------|
| Zsh | `~/.zshrc`, `~/.motd` |
| Tmux | `~/.tmux.conf` |
| Neovim | `~/.config/nvim/` |
| Vim | `~/.vimrc` |
| Ghostty | `~/.config/ghostty/config` |
| WezTerm | `~/.wezterm.lua` |
| Starship | `~/.config/starship-{pastel,rainbow,tokyo-night}.toml` |
| Powerlevel10k | `~/.p10k.zsh` |
| k9s | `~/.config/k9s/` |
| VSCode | `~/Library/Application Support/Code/User/settings.json` (macOS) |

### Per-machine overrides

Two files are **copied** (not symlinked) on first run so each machine can
diverge without affecting others:

- `~/.zsh_config_overrides` — set `CUST_PROMPT`, `STARSHIP_PRESET`, `MOTD_TYPE`,
  and related vars to customise the shell prompt and MOTD per machine
- `~/.wezterm_overrides.lua` — machine-specific WezTerm settings (font size,
  opacity, etc.)

Edit these directly on each machine after running `setup.sh`.

## Install Dependencies

### macOS

```sh
# Install homebrew (https://brew.sh/)
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Initialize homebrew for this session
eval "$(${BREW_PREFIX}/bin/brew shellenv)"

# Install bundle with homebrew
brew bundle install --file Brewfile.osx
```

### Linux (Debian / Ubuntu)

```sh
# Install packages
sudo apt-get install -y build-essential zsh git wget curl nodejs ncal unzip xsel vim libwebkit2gtk-4.0-dev

# libwebkit2gtk-4.0-dev is required for the peek.nvim markdown preview plugin.
# On Debian 12 (Bookworm) or newer, use libwebkit2gtk-4.1-dev instead.

# For system-clipboard support in plain `vim`, check that the build has it:
#   vim --version | grep -o '[+-]clipboard'
# A '-clipboard' build cannot talk to the clipboard at all; install a build
# that can (vim-gtk3 provides +clipboard and +X11). Neovim is unaffected —
# it shells out to a clipboard provider instead of needing X11.

# Install WezTerm
curl -fsSL https://apt.fury.io/wez/gpg.key | sudo gpg --yes --dearmor -o /usr/share/keyrings/wezterm-fury.gpg
echo 'deb [signed-by=/usr/share/keyrings/wezterm-fury.gpg] https://apt.fury.io/wez/ * *' | sudo tee /etc/apt/sources.list.d/wezterm.list
sudo apt update
sudo apt -y install wezterm

# Install Ghostty — see https://ghostty.org/docs/install/binary

# Change shell to zsh
touch ~/.zshrc
chsh -s $(which zsh)

# Switch to zsh session
$(which zsh)

# Install homebrew (https://brew.sh/)
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Initialize homebrew for this session
eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"

# Install bundle with homebrew
brew bundle install --file Brewfile.linux

# Install VSCode
VSCODE_DOWNLOAD=~/Downloads/vscode-latest.deb
curl -o "$VSCODE_DOWNLOAD" -L "https://code.visualstudio.com/sha/download?build=stable&os=linux-deb-x64"
sudo dpkg -i "$VSCODE_DOWNLOAD"
```

### AI CLIs (Codex + Claude Code + Cursor)

All three are installed automatically when you run `./setup.sh` (enabled by default).
Disable per machine in `setup.conf`:

```sh
SETUP_CODEX_CLI=false
SETUP_CLAUDE_CODE=false
SETUP_CURSOR_CLI=false
```

| Tool | Command | macOS / Linux installer |
|------|---------|-------------------------|
| Codex CLI | `codex` | Official standalone installer |
| Claude Code | `claude` | Official native installer |
| Cursor CLI | `cursor-agent` | Official CLI installer |

Authentication is manual and per-user — run each command once after install to
log in via your browser. `setup.sh` cannot script this step.

Verify after install:

```sh
codex --version
claude --version
cursor-agent --version
```

The installers place their binaries under `~/.local/bin`, which this repo adds
to `PATH`. To install one manually, use the same commands as `setup.sh`:

```sh
curl -fsSL https://chatgpt.com/codex/install.sh | sh
curl -fsSL https://claude.ai/install.sh | bash
curl -fsSL https://cursor.com/install | bash
```

See the [Codex CLI](https://learn.chatgpt.com/docs/codex/cli),
[Claude Code](https://code.claude.com/docs/en/quickstart), and
[Cursor CLI](https://docs.cursor.com/en/cli/installation) installation docs.

### tfswitch (Terraform / OpenTofu version switcher)

Installed automatically by `./setup.sh` on both macOS and Linux (enabled by
default). Disable per machine in `setup.conf`:

```sh
SETUP_TFSWITCH=false
```

The official installer covers `darwin` and `linux` on both `amd64` and `arm64`,
and `setup.sh` points it at `~/.local/bin` so no `sudo` is required:

```sh
curl -fsSL https://raw.githubusercontent.com/warrensbox/terraform-switcher/release/install.sh \
  | bash -s -- -b "$HOME/.local/bin"
```

Verify with `tfswitch --version`. Run `tfswitch` in a directory to pick a
Terraform version, or `tfswitch --tofu` for OpenTofu — this environment leans
OpenTofu: `zshrc` exports `TERRAPRISM_TOFU=1` and the `tf_lint` helper shells
out to `tofu fmt`.

See the [tfswitch docs](https://warrensbox.github.io/terraform-switcher).

## Optional Dependencies

**Rust**
```sh
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
```

**Deno** (required for the peek.nvim markdown preview plugin)
```sh
brew install deno
```

## Install Configurations

```sh
./setup.sh
```

`setup.sh` is safe to re-run at any time. On subsequent runs it:
- Skips symlinks that are already correct
- Replaces stale symlinks (e.g. after moving the repo)
- Pulls updates for managed git repos (tpm, figlet-fonts, vim-tmux-navigator)
- Never overwrites your per-machine override files
- Skips AI CLI installs when `codex`, `claude`, or `cursor-agent` is already on PATH
- Skips the tfswitch install when `tfswitch` is already on PATH
- Converges Neovim plugins to the tracked `lazy-lock.json` (`SETUP_NVIM_SYNC`)

### Customising what gets installed

On first run, `setup.sh` auto-copies `setup.conf.template` to `setup.conf`
(ignored by git). Edit `setup.conf` to enable or disable individual sections
for that machine — useful for servers that don't need a GUI terminal config,
or machines where only a subset of tools is installed.

```sh
cp setup.conf.template setup.conf
$EDITOR setup.conf
```

## Neovim plugin versions

`configs/nvim/lazy-lock.json` is **tracked in git**, so every machine runs
identical plugin versions. `./setup.sh` applies it by running `:Lazy clean`,
`:Lazy install`, and `:Lazy restore` headlessly. Disable that step per machine
with `SETUP_NVIM_SYNC=false` in `setup.conf`.

Updating plugins is deliberate, not automatic:

```sh
nvim                     # then :Lazy update, and verify things still work
cd path/to/this/repo
git add configs/nvim/lazy-lock.json
git commit -m "Update nvim plugins"
```

Other machines pick the new versions up on their next `git pull && ./setup.sh`.
Avoid `:Lazy sync` in scripts — it updates plugins and defeats the lockfile.

See [`CHANGELOG.md`](CHANGELOG.md) for the current Neovim version requirement
and the list of deferred plugin migrations.

## Other macOS Customizations

### Disable autocorrections

```sh
defaults write NSGlobalDomain NSAutomaticSpellingCorrectionEnabled -bool false
defaults write NSGlobalDomain NSAutomaticCapitalizationEnabled -bool false
defaults write NSGlobalDomain NSAutomaticPeriodSubstitutionEnabled -bool false
defaults write NSGlobalDomain NSAutomaticDashSubstitutionEnabled -bool false
defaults write NSGlobalDomain NSAutomaticQuoteSubstitutionEnabled -bool false
defaults write NSGlobalDomain NSTextReplacementEnabled -bool false
```

## License

Licensed under the [Apache License, Version 2.0](https://www.apache.org/licenses/LICENSE-2.0).

```
Copyright 2026 Jen Reed

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
```

# nix-terminal-env

Personal terminal environment and development tool configurations, maintained
across macOS, Debian Linux desktop, and home lab Linux servers.

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

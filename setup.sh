#!/usr/bin/env bash
# This script basically symlinks all the config files to the appropriate directories

GREEN=$(tput setaf 2)
YELLOW=$(tput setaf 3)
RED=$(tput setaf 1)
RESET=$(tput sgr0)

log_info() {
  echo -e "${GREEN}[INFO]: $* ${RESET}"
}

log_warning() {
  echo -e "${YELLOW}[WARN]: $* ${RESET}"
}

log_error() {
  echo -e "${RED}[ERROR]: $* ${RESET}"
}

BASE_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# ---------------------------------------------------------------------------
# Load per-machine config
# ---------------------------------------------------------------------------

SETUP_CONF="$BASE_DIR/setup.conf"
SETUP_CONF_TEMPLATE="$BASE_DIR/setup.conf.template"

if [ ! -f "$SETUP_CONF" ]; then
    log_warning "No setup.conf found — copying from template. Edit $SETUP_CONF to customise."
    cp "$SETUP_CONF_TEMPLATE" "$SETUP_CONF"
fi

# shellcheck source=setup.conf.template
source "$SETUP_CONF"

# is_enabled <var> — returns true if the value is "true" or unset (default on)
is_enabled() {
    [[ "${1:-true}" == "true" ]]
}

# ---------------------------------------------------------------------------
# Shared helpers
# ---------------------------------------------------------------------------

# link_config <src> <dest>
#   Creates a symlink at <dest> pointing to <src>.
#   - Skips if the symlink already points to <src>.
#   - Removes stale symlinks (pointing elsewhere) before re-linking.
#   - Backs up existing regular files or directories before replacing.
#   - Creates parent directories as needed.
link_config() {
    local src="$1"
    local dest="$2"

    if [ ! -e "$src" ]; then
        log_error "Source not found: $src"
        return 1
    fi

    # Already correct — nothing to do
    if [ -L "$dest" ] && [ "$(readlink "$dest")" = "$src" ]; then
        return 0
    fi

    # Stale symlink pointing elsewhere — replace it
    if [ -L "$dest" ]; then
        log_warning "Removing stale symlink: $dest -> $(readlink "$dest")"
        rm -f "$dest"
    elif [ -e "$dest" ]; then
        log_warning "Backing up $dest to $dest.bak"
        mv "$dest" "$dest.bak"
    fi

    mkdir -p "$(dirname "$dest")"
    log_warning "Linking $dest -> $src"
    ln -sf "$src" "$dest"
}

# clone_or_update <url> <dest> <label>
#   Clones <url> into <dest> on first run; pulls updates on subsequent runs.
#   Recovers automatically when upstream renames its default branch (the
#   master -> main migration), which otherwise breaks `pull` forever.
clone_or_update() {
    local url="$1"
    local dest="$2"
    local label="$3"

    if [ ! -d "$dest/.git" ]; then
        log_warning "Cloning $label to $dest"
        mkdir -p "$(dirname "$dest")"
        if ! git clone "$url" "$dest"; then
            log_error "Failed to clone $label from $url"
            return 1
        fi
        return 0
    fi

    log_info "Updating $label"

    local pull_output
    if pull_output=$(git -C "$dest" pull --ff-only 2>&1); then
        return 0
    fi

    # Pull failed. Never touch a checkout with local edits.
    if [ -n "$(git -C "$dest" status --porcelain)" ]; then
        log_warning "$label has local changes; leaving it alone"
        return 0
    fi

    if ! git -C "$dest" fetch --quiet --prune origin 2>/dev/null; then
        log_warning "Could not fetch $label (offline?)"
        return 0
    fi

    # Ask the remote what its default branch is now
    git -C "$dest" remote set-head origin --auto > /dev/null 2>&1
    local default_branch
    default_branch=$(git -C "$dest" symbolic-ref --quiet --short refs/remotes/origin/HEAD 2>/dev/null)
    default_branch="${default_branch#origin/}"

    if [ -z "$default_branch" ]; then
        log_warning "Could not update $label and could not determine its default branch"
        echo "$pull_output" | sed 's/^/    /'
        return 0
    fi

    local current_branch
    current_branch=$(git -C "$dest" rev-parse --abbrev-ref HEAD 2>/dev/null)

    if [ "$current_branch" != "$default_branch" ]; then
        log_warning "$label: upstream default branch is now '$default_branch' (was '$current_branch')"
    fi

    if git -C "$dest" checkout --quiet -B "$default_branch" --track "origin/$default_branch" 2>/dev/null; then
        log_info "$label re-pointed at origin/$default_branch"
    else
        log_warning "Could not update $label (offline or diverged?)"
        echo "$pull_output" | sed 's/^/    /'
    fi
}

# ---------------------------------------------------------------------------

vscode_key_repeating_issues() {
    if [[ "$(uname)" == "Darwin" ]]; then
        # Fixes vim repeat in VSCode using vim plugin
        defaults write com.microsoft.VSCode ApplePressAndHoldEnabled -bool false
        defaults write com.microsoft.VSCodeInsiders ApplePressAndHoldEnabled -bool false
        defaults write com.visualstudio.code.oss ApplePressAndHoldEnabled -bool false

        # Fixes period added for multiple spaces
        defaults write NSGlobalDomain NSAutomaticPeriodSubstitutionEnabled -bool false
    fi
}

download_and_extract_font() {
    log_info "Checking Nerd Font Hack font..."
    local url="https://github.com/ryanoasis/nerd-fonts/releases/download/v3.2.1/Hack.zip"
    local extract_to="$HOME/.fonts"
    local zip_file="$extract_to/Hack.zip"

    mkdir -p "$extract_to"

    if ! ls ~/.fonts/HackNerdFont*.ttf &> /dev/null; then
        log_info "Downloading Nerd Font Hack font..."
        curl -L -o "$zip_file" "$url"
        unzip -o "$zip_file" -d "$extract_to"
        rm "$zip_file"
    fi

    if command -v fc-cache &> /dev/null; then
        log_info "Using fc-cache command to update font cache"
        fc-cache -f
    else
        log_error "fc-cache command not found. Please install fontconfig package."
    fi
}

replace_vscode_settings() {
    log_info "VSCode settings.json"
    local settings_file="$BASE_DIR/configs/vscode/settings.json"
    local vscode_settings_dir

    if [[ "$(uname)" == "Darwin" ]]; then
        vscode_settings_dir="$HOME/Library/Application Support/Code/User"
    else
        vscode_settings_dir="$HOME/.config/Code/User"
    fi

    if [ ! -f "$settings_file" ]; then
        log_error "vscode settings.json not found in repo"
        return 1
    fi

    mkdir -p "$vscode_settings_dir"
    link_config "$settings_file" "$vscode_settings_dir/settings.json"
}

check_commands() {
    log_info "Checking for required command line utilities"
    local commands=("git" "lolcat" "figlet")
    local missing_commands=()

    for cmd in "${commands[@]}"; do
        if ! command -v "$cmd" &> /dev/null; then
            missing_commands+=("$cmd")
        fi
    done

    if [ ${#missing_commands[@]} -gt 0 ]; then
        log_error "Missing commands: ${missing_commands[*]}"
        if [[ "$(uname)" == "Darwin" ]]; then
            log_error "Please install the missing commands using Homebrew by running 'brew bundle' before running the setup script."
        else
            log_error "Please install the missing commands before running the setup script."
        fi
        exit 1
    fi
}

check_figlet_fonts() {
    log_info "Checking for figlet-fonts repository"
    clone_or_update "https://github.com/xero/figlet-fonts" "$HOME/.local/share/figlet-fonts" "figlet-fonts"
}

check_tmux_tpm_plugin() {
    log_info "Checking for tmux plugin manager"
    mkdir -p "$HOME/.tmux/plugins"
    clone_or_update "https://github.com/tmux-plugins/tpm" "$HOME/.tmux/plugins/tpm" "tpm"
}

link_zsh_files() {
    log_info "Linking zsh files"
    local files=("zshrc" "motd")
    for file in "${files[@]}"; do
        link_config "$BASE_DIR/configs/zsh/$file" "$HOME/.$file"
    done
}

copy_zsh_overrides_config() {
    log_info "Checking for ~/.zsh_config_overrides file"
    local overrides_file="$BASE_DIR/configs/zsh/zsh_config_overrides"

    if [ ! -f "${HOME}/.zsh_config_overrides" ]; then
        log_warning "Copying zsh_config_overrides to ~/.zsh_config_overrides"
        cp "$overrides_file" "${HOME}/.zsh_config_overrides"
    fi
}

check_starship_config() {
    log_info "Checking starship configs"
    local starship_config_dir="$HOME/.config"
    local starship_repo_config_dir="$BASE_DIR/configs/starship"

    # Remove only symlinks matching starship*.toml — never delete real files
    for f in "$starship_config_dir"/starship*.toml; do
        [ -L "$f" ] && rm -f "$f"
    done

    for config in "$starship_repo_config_dir"/*.toml; do
        ln -sf "$config" "$starship_config_dir/$(basename "$config")"
    done
}

check_powerlevel10k_config() {
    log_info "Checking powerlevel10k config"
    link_config "$BASE_DIR/configs/powerlevel10k/p10k.zsh" "$HOME/.p10k.zsh"
}

create_tmux_symlink() {
    log_info "Creating tmux config symlink"
    link_config "$BASE_DIR/configs/tmux/tmux.conf" "$HOME/.tmux.conf"
}

vim_plugins() {
    local vim_plugins_dir="${HOME}/.vim/pack/plugins/start"
    mkdir -p "${vim_plugins_dir}"
    clone_or_update "https://github.com/christoomey/vim-tmux-navigator.git" "${vim_plugins_dir}/vim-tmux-navigator" "vim-tmux-navigator"
}

create_nvim_symlink() {
    log_info "Checking nvim config links"
    link_config "$BASE_DIR/configs/nvim" "$HOME/.config/nvim"
}

create_wezterm_symlink() {
    log_info "Checking wezterm config links"
    link_config "$BASE_DIR/configs/wezterm/wezterm.lua" "$HOME/.wezterm.lua"
}

create_ghostty_symlink() {
    log_info "Checking ghostty config links"
    link_config "$BASE_DIR/configs/ghostty/config" "$HOME/.config/ghostty/config"
}

copy_wezterm_overrides_config() {
    log_info "Checking for ~/.wezterm_overrides.lua file"
    local overrides_file="$BASE_DIR/configs/wezterm/wezterm_overrides.lua"

    if [ ! -f "${HOME}/.wezterm_overrides.lua" ]; then
        log_warning "Copying wezterm_overrides.lua to ~/.wezterm_overrides.lua"
        cp "$overrides_file" "${HOME}/.wezterm_overrides.lua"
    fi
}

create_vimrc_symlink() {
    log_info "Checking vimrc config symlink"
    link_config "$BASE_DIR/configs/vim/vimrc" "$HOME/.vimrc"
}

create_k9s_symlink() {
    log_info "Checking k9s config symlink"
    link_config "$BASE_DIR/configs/k9s" "$HOME/.config/k9s"
}

install_codex_cli() {
    log_info "Checking Codex CLI..."

    if command -v codex &> /dev/null; then
        log_info "Codex CLI already installed: $(codex --version 2>/dev/null || echo "ok")"
        return 0
    fi

    log_info "Installing Codex CLI..."
    if ! (set -o pipefail; curl -fsSL https://chatgpt.com/codex/install.sh | sh); then
        log_error "Codex CLI install failed"
        log_error "Retry manually: curl -fsSL https://chatgpt.com/codex/install.sh | sh"
        return 1
    fi

    if command -v codex &> /dev/null; then
        log_info "Codex CLI installed: $(codex --version 2>/dev/null || echo "ok")"
    else
        log_warning "Codex CLI install completed but 'codex' was not found in PATH"
        log_warning "Ensure ~/.local/bin is in your PATH (already configured in zshrc)"
    fi
}

install_claude_code() {
    log_info "Checking Claude Code CLI..."

    if command -v claude &> /dev/null; then
        log_info "Claude Code already installed: $(claude --version 2>/dev/null || echo "ok")"
        return 0
    fi

    log_info "Installing Claude Code CLI..."
    if ! (set -o pipefail; curl -fsSL https://claude.ai/install.sh | bash); then
        log_error "Claude Code install failed"
        log_error "Retry manually: curl -fsSL https://claude.ai/install.sh | bash"
        return 1
    fi

    if command -v claude &> /dev/null; then
        log_info "Claude Code installed: $(claude --version 2>/dev/null || echo "ok")"
    else
        log_warning "Claude Code install completed but 'claude' not found in PATH"
    fi
}

install_cursor_cli() {
    log_info "Checking Cursor CLI..."

    if command -v cursor-agent &> /dev/null; then
        log_info "Cursor CLI already installed: $(cursor-agent --version 2>/dev/null || echo "ok")"
        return 0
    fi

    log_info "Installing Cursor CLI..."
    if ! (set -o pipefail; curl -fsSL https://cursor.com/install | bash); then
        log_error "Cursor CLI install failed"
        log_error "Retry manually: https://cursor.com/docs/cli/installation"
        return 1
    fi

    if command -v cursor-agent &> /dev/null; then
        log_info "Cursor CLI installed: $(cursor-agent --version 2>/dev/null || echo "ok")"
    else
        log_warning "Cursor CLI install completed but 'cursor-agent' was not found in PATH"
        log_warning "Ensure ~/.local/bin is in your PATH (already configured in zshrc)"
    fi
}

install_tfswitch() {
    log_info "Checking tfswitch..."

    if command -v tfswitch &> /dev/null; then
        log_info "tfswitch already installed: $(tfswitch --version 2>/dev/null || echo "ok")"
        return 0
    fi

    # Official installer covers darwin/linux on amd64 and arm64.
    # -b keeps it in ~/.local/bin so no sudo is needed (already on PATH via zshrc).
    log_info "Installing tfswitch..."
    local install_url="https://raw.githubusercontent.com/warrensbox/terraform-switcher/release/install.sh"
    if ! (set -o pipefail; curl -fsSL "$install_url" | bash -s -- -b "$HOME/.local/bin"); then
        log_error "tfswitch install failed"
        log_error "Retry manually: curl -fsSL $install_url | bash -s -- -b \"\$HOME/.local/bin\""
        return 1
    fi

    if command -v tfswitch &> /dev/null; then
        log_info "tfswitch installed: $(tfswitch --version 2>/dev/null || echo "ok")"
    else
        log_warning "tfswitch install completed but 'tfswitch' was not found in PATH"
        log_warning "Ensure ~/.local/bin is in your PATH (already configured in zshrc)"
    fi
}

# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------

check_commands

# AI CLIs
if is_enabled "$SETUP_CODEX_CLI"; then
    install_codex_cli
fi

if is_enabled "$SETUP_CLAUDE_CODE"; then
    install_claude_code
fi

if is_enabled "$SETUP_CURSOR_CLI"; then
    install_cursor_cli
fi

# Terraform / OpenTofu version switcher
if is_enabled "$SETUP_TFSWITCH"; then
    install_tfswitch
fi

# Zsh
if is_enabled "$SETUP_ZSH"; then
    link_zsh_files
    copy_zsh_overrides_config
fi

# Starship prompt configs
if is_enabled "$SETUP_STARSHIP"; then
    check_starship_config
fi

# Figlet fonts
if is_enabled "$SETUP_FIGLET_FONTS"; then
    check_figlet_fonts
fi

# Nerd Font (Linux only)
if is_enabled "$SETUP_NERD_FONTS" && [[ "$(uname)" == "Linux" ]]; then
    download_and_extract_font
fi

# Ghostty
if is_enabled "$SETUP_GHOSTTY" && command -v ghostty &> /dev/null; then
    create_ghostty_symlink
fi

# WezTerm
if is_enabled "$SETUP_WEZTERM" && command -v wezterm &> /dev/null; then
    create_wezterm_symlink
    copy_wezterm_overrides_config
fi

# Neovim
if is_enabled "$SETUP_NVIM" && command -v nvim &> /dev/null; then
    create_nvim_symlink
fi

# Vim
if is_enabled "$SETUP_VIM"; then
    create_vimrc_symlink
    vim_plugins
fi

# VSCode
if is_enabled "$SETUP_VSCODE"; then
    if [ -d "$HOME/Library/Application Support/Code/" ] || command -v code &> /dev/null; then
        vscode_key_repeating_issues
        replace_vscode_settings
        log_warning "Please open this directory in VSCode in order to get a prompt for recommended extensions..."
    fi
fi

# Tmux
if is_enabled "$SETUP_TMUX" && command -v tmux &> /dev/null; then
    create_tmux_symlink
    check_tmux_tpm_plugin
    check_powerlevel10k_config
    log_warning "Please initialize tmux plugin manager by pressing 'prefix + I' in tmux..."
fi

# k9s
if is_enabled "$SETUP_K9S" && command -v k9s &> /dev/null; then
    create_k9s_symlink
fi

# ---------------------------------------------------------------------------
# Post-install reminders
# ---------------------------------------------------------------------------

log_info "Setup complete."
log_info "The following override files are machine-specific and not tracked by git."
log_info "Review and edit them to customise this machine's environment:"
echo ""
echo "  ${YELLOW}~/.zsh_config_overrides${RESET}    — shell prompt, starship preset, MOTD style"
echo "  ${YELLOW}~/.wezterm_overrides.lua${RESET}   — WezTerm font size, opacity, and other local tweaks"
echo ""
if is_enabled "$SETUP_CODEX_CLI" || is_enabled "$SETUP_CLAUDE_CODE" || is_enabled "$SETUP_CURSOR_CLI"; then
    log_info "Authenticate AI CLIs on first use (browser login):"
    if is_enabled "$SETUP_CODEX_CLI"; then
        echo "  Run ${YELLOW}codex${RESET} once to authenticate Codex CLI"
    fi
    if is_enabled "$SETUP_CLAUDE_CODE"; then
        echo "  Run ${YELLOW}claude${RESET} once to authenticate Claude Code"
    fi
    if is_enabled "$SETUP_CURSOR_CLI"; then
        echo "  Run ${YELLOW}cursor-agent login${RESET} to authenticate Cursor CLI"
    fi
    echo ""
fi

#!/bin/bash
# This script basically symlinks all the config files to the appropriate directories

BASE_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

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

replace_vscode_settings() {
    local settings_file=""
    local vscode_settings_dir=""

    settings_file="$BASE_DIR/configs/vscode/settings.json"
    if [[ "$(uname)" == "Darwin" ]]; then
        vscode_settings_dir="$HOME/Library/Application Support/Code/User"
    else
        vscode_settings_dir="$HOME/.config/Code/User"
    fi

    if [ -f "$settings_file" ]; then
        if [ -f "$vscode_settings_dir/settings.json" ]; then
            if [ ! -L "$vscode_settings_dir/settings.json" ]; then
               echo "Backing up existing settings.json to settings.json.bak"
               mv "$vscode_settings_dir/settings.json" "$vscode_settings_dir/settings.json.bak"
            fi
        fi

        if [ ! -L "$vscode_settings_dir/settings.json" ]; then
            echo "Linking settings.json to $vscode_settings_dir/settings.json"
            ln -sf "$settings_file" "$vscode_settings_dir/settings.json"
        fi
    else
        echo "Error: vscode settings.json not found"
        exit 1
    fi
}

check_commands() {
    commands=("git" "lolcat" "figlet")

    missing_commands=()
    for cmd in "${commands[@]}"; do
        if ! command -v "$cmd" &> /dev/null; then
            missing_commands+=("$cmd")
        fi
    done

    if [ ${#missing_commands[@]} -gt 0 ]; then
        echo "Missing commands: ${missing_commands[@]}"
        if [[ "$(uname)" == "Darwin" ]]; then
            echo "Please install the missing commands using Homebrew by running 'brew bundle' before running the setup script."
        else
            echo "Please install the missing commands before running the setup script."
        fi
        exit 1
    fi
}

check_figlet_fonts() {
    local figlet_fonts_dir="$HOME/.local/share/figlet-fonts"

    if [ ! -d "$figlet_fonts_dir" ]; then
        echo "Cloning figlet-fonts repository to $figlet_fonts_dir"
        git clone https://github.com/xero/figlet-fonts "$figlet_fonts_dir"
    fi
}

link_zsh_files() {
    files=(".zshrc" ".motd")
    for file in "${files[@]}"; do
        if [ -f "$HOME/$file" ]; then
            if [ ! -L "$HOME/$file" ]; then
                echo "Backing up existing $file to $file.bak"
                mv "$HOME/$file" "$HOME/$file.bak"
            fi
        fi
        if [ ! -L "$HOME/$file" ]; then
            echo "Linking $file to $BASE_DIR/configs/zsh/$file"
            ln -s "$BASE_DIR/configs/zsh/$file" "$HOME/$file"
        fi

    done
}

check_starship_config() {
    local starship_config="$HOME/.config/starship.toml"
    local starship_repo_config="$BASE_DIR/configs/starship/starship.toml"

    if [ -f "$starship_config" ]; then
        if [ ! -L "$starship_config" ]; then
            echo "Backing up existing starship.toml to starship.toml.bak"
            mv "$starship_config" "$starship_config.bak"
        fi
    fi

    if [ ! -L "$starship_config" ]; then
       echo "Creating symlink for starship.toml"
       ln -sf "$starship_repo_config" "$starship_config"
    fi
}

create_tmux_symlink() {
    local tmux_config="$HOME/.tmux.conf"
    local tmux_repo_config="$BASE_DIR/configs/tmux/.tmux.conf"

    if [ -f "$tmux_config" ]; then
        if [ ! -L "$tmux_config" ]; then
            echo "Backing up existing tmux config to $tmux_config.bak"
            mv "$tmux_config" "$tmux_config.bak"
        fi
    fi

    if [ ! -L "$tmux_config" ]; then
        echo "Creating symlink for tmux config"
        ln -sf "$tmux_repo_config" "$tmux_config"
    fi
}

create_nvim_symlink() {
    local nvim_config="$HOME/.config/nvim"
    local nvim_repo_config="$BASE_DIR/configs/nvim"

    if [ -d "$nvim_config" ]; then
        if [ ! -L "$nvim_config" ]; then
           echo "Backing up existing nvim config to $nvim_config.bak"
           mv "$nvim_config" "$nvim_config.bak"
        fi
    fi

    if [ ! -L "$nvim_config" ]; then
        echo "Creating symlink for nvim config"
        ln -sf "$nvim_repo_config" "$nvim_config"
    fi
}

create_wezterm_symlink() {
    local wezterm_config="$HOME/.wezterm.lua"
    local wezterm_repo_config="$BASE_DIR/configs/wezterm/wezterm.lua"

    if [ -f "$wezterm_config" ]; then
        if [ ! -L "$wezterm_config" ]; then
            echo "Backing up existing wezterm config to $wezterm_config.bak"
            mv "$wezterm_config" "$wezterm_config.bak"
        fi
    fi

    if [ ! -L "$wezterm_config" ]; then
        echo "Creating symlink for wezterm config"
        ln -sf "$wezterm_repo_config" "$wezterm_config"
    fi
}

# Check for required commands for this script
check_commands

# Terminal Config Linking
link_zsh_files
check_figlet_fonts
check_starship_config

# Tmux Config Linking
if command -v tmux &> /dev/null; then
    create_tmux_symlink
fi

# Neovim IDE Config Linking
if command -v nvim &> /dev/null; then
    create_nvim_symlink
fi

# WezTerm Terminal Config Linking
if command -v wezterm &> /dev/null; then
    create_wezterm_symlink
fi

# Stuff for VSCode IDE
if [ -d "$HOME/Library/Application Support/Code/" ] || command -v code &> /dev/null; then
    vscode_key_repeating_issues
    replace_vscode_settings

    echo "Please open this directory in VSCode in order to get a prompt for recommended extensions..."
fi

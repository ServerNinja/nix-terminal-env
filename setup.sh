#!/usr/bin/env bash
# This script basically symlinks all the config files to the appropriate directories

export GREEN=`tput setaf 2`
export YELLOW=`tput setaf 3`
export RED=`tput setaf 1`
export RESET=`tput sgr0`

log_info() {
  echo -e "$GREEN[INFO]: $@ $RESET"
}

log_warning() {
  echo -e "$YELLOW[WARN]: $@ $RESET"
}

log_error() {
  echo -e "$RED[ERROR]: $@ $RESET"
}

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

download_and_extract_font() {
    log_info "Nerd Font Hack font..."
    local url="https://github.com/ryanoasis/nerd-fonts/releases/download/v3.2.1/Hack.zip"
    local extract_to="$HOME/.fonts"
    local zip_file="$extract_to/Hack.zip"

    # Ensure the target directory exists
    mkdir -p "$extract_to"

    if ! ls ~/.fonts/HackNerdFont*.ttf &> /dev/null; then
      log_info "Downloading Nerd Font Hack font..."
      # Download the file
      curl -L -o "$zip_file" "$url"
  
      # Extract the zip file
      unzip -o "$zip_file" -d "$extract_to"
  
      # Clean up the zip file
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
               log_warning "Backing up existing settings.json to settings.json.bak"
               mv "$vscode_settings_dir/settings.json" "$vscode_settings_dir/settings.json.bak"
            fi
        fi

        if [ ! -L "$vscode_settings_dir/settings.json" ]; then
            log_warning "Linking settings.json to $vscode_settings_dir/settings.json"
            ln -sf "$settings_file" "$vscode_settings_dir/settings.json"
        fi
    else
        log_error "Error: vscode settings.json not found"
        exit 1
    fi
}

check_commands() {
    log_info "Checking for required command line utilities"
    commands=("git" "lolcat" "figlet")

    missing_commands=()
    for cmd in "${commands[@]}"; do
        if ! command -v "$cmd" &> /dev/null; then
            missing_commands+=("$cmd")
        fi
    done

    if [ ${#missing_commands[@]} -gt 0 ]; then
        log_error "Missing commands: ${missing_commands[@]}"
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
    local figlet_fonts_dir="$HOME/.local/share/figlet-fonts"

    if [ ! -d "$figlet_fonts_dir" ]; then
        log_warning "Cloning figlet-fonts repository to $figlet_fonts_dir"
        git clone https://github.com/xero/figlet-fonts "$figlet_fonts_dir"
    fi
}

check_tmux_tpm_plugin() {
    log_info "Checking for tmux plugin manager"
    # git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
    local tmux_plugin_dir="$HOME/.tmux/plugins"

    # Check for the tmux plugin manager directory
    if [ ! -d "$tmux_plugin_dir" ]; then
        mkdir -p "$tmux_plugin_dir"
    fi  

    # Check for the tpm directory
    if [ ! -d "$tmux_plugin_dir/tpm" ]; then
        log_warning "Cloning tpm repository to $tmux_plugin_dir/tpm"
        git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
    fi
}

link_zsh_files() {
    log_info "Linking zsh files"
    files=(".zshrc" ".motd")
    for file in "${files[@]}"; do
        if [ -f "$HOME/$file" ]; then
            if [ ! -L "$HOME/$file" ]; then
                log_warning "Backing up existing $file to $file.bak"
                mv "$HOME/$file" "$HOME/$file.bak"
            fi
        fi
        if [ ! -L "$HOME/$file" ]; then
            log_warning "Linking $file to $BASE_DIR/configs/zsh/$file"
            ln -s "$BASE_DIR/configs/zsh/$file" "$HOME/$file"
        fi

    done
}

check_starship_config() {
    log_info "Checking starship config"
    local starship_config="$HOME/.config/starship.toml"
    local starship_repo_config="$BASE_DIR/configs/starship/starship.toml"

    if [ -f "$starship_config" ]; then
        if [ ! -L "$starship_config" ]; then
            log_warning "Backing up existing starship.toml to starship.toml.bak"
            mv "$starship_config" "$starship_config.bak"
        fi
    fi

    if [ ! -L "$starship_config" ]; then
       log_warning "Creating symlink for starship.toml"
       ln -sf "$starship_repo_config" "$starship_config"
    fi
}

check_powerlevel10k_config() {
    log_info "Checking powerlevel10k config"
    local powerlevel10k_config="$HOME/.p10k.zsh"
    local powerlevel10k_repo_config="$BASE_DIR/configs/powerlevel10k/p10k.zsh"

    if [ -f "$powerlevel10k_config" ]; then
        if [ ! -L "$powerlevel10k_config" ]; then
            log_warning "Backing up existing p10k.toml to p10k.toml.bak"
            mv "$powerlevel10k_config" "$powerlevel10k_config.bak"
        fi
    fi

    if [ ! -L "$powerlevel10k_config" ]; then
       log_warning "Creating symlink for p10k.toml"
       ln -sf "$powerlevel10k_repo_config" "$powerlevel10k_config"
    fi
}

create_tmux_symlink() {
    log_info "Creating tmux config symlink"
    local tmux_config="$HOME/.tmux.conf"
    local tmux_repo_config="$BASE_DIR/configs/tmux/tmux.conf"

    if [ -f "$tmux_config" ]; then
        if [ -L "$tmux_config" ]; then
            if ! [ "$(readlink "$tmux_config")" == "$tmux_repo_config" ]; then
                rm -f "$tmux_config"
            fi
        else
            log_warning "Backing up existing tmux config to $tmux_config.bak"
            mv "$tmux_config" "$tmux_config.bak"
        fi
    fi

    if [ ! -L "$tmux_config" ]; then
        log_warning "Creating symlink for tmux config"
        ln -sf "$tmux_repo_config" "$tmux_config"
    fi
}

create_nvim_symlink() {
    log_info "Checking nvim config links"
    local nvim_config="$HOME/.config/nvim"
    local nvim_repo_config="$BASE_DIR/configs/nvim"

    if [ -d "$nvim_config" ]; then
        if [ ! -L "$nvim_config" ]; then
           log_warning "Backing up existing nvim config to $nvim_config.bak"
           mv "$nvim_config" "$nvim_config.bak"
        fi
    fi

    if [ ! -L "$nvim_config" ]; then
        log_warning "Creating symlink for nvim config"
        ln -sf "$nvim_repo_config" "$nvim_config"
    fi
}

create_wezterm_symlink() {
    log_info "Checking wezterm config links"
    local wezterm_config="$HOME/.wezterm.lua"
    local wezterm_repo_config="$BASE_DIR/configs/wezterm/wezterm.lua"

    if [ -f "$wezterm_config" ]; then
        if [ ! -L "$wezterm_config" ]; then
            log_warning "Backing up existing wezterm config to $wezterm_config.bak"
            mv "$wezterm_config" "$wezterm_config.bak"
        fi
    fi

    if [ ! -L "$wezterm_config" ]; then
        log_warning "Creating symlink for wezterm config"
        ln -sf "$wezterm_repo_config" "$wezterm_config"
    fi
}

# Check for required commands for this script
check_commands

# Terminal Config Linking
link_zsh_files
check_figlet_fonts
check_starship_config

# Nerd Font for linux
if [[ "$(uname)" == "Linux" ]]; then
  download_and_extract_font
fi

# Neovim IDE Config Linking
if command -v nvim &> /dev/null; then
    create_nvim_symlink
fi

# WezTerm Terminal Config Linking
if command -v wezterm &> /dev/null; then
    create_wezterm_symlink
fi

# Tmux Config Linking
if command -v tmux &> /dev/null; then
    create_tmux_symlink
    check_tmux_tpm_plugin
    check_powerlevel10k_config
    
    log_warning "Please initialize tmux plugin manager by pressing 'prefix + I' in tmux..."
fi

# Stuff for VSCode IDE
if [ -d "$HOME/Library/Application Support/Code/" ] || command -v code &> /dev/null; then
    vscode_key_repeating_issues
    replace_vscode_settings

    log_warning "Please open this directory in VSCode in order to get a prompt for recommended extensions..."
fi

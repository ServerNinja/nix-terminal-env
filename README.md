# nix-terminal-env

## Install Dependencies

OS: Linux (debian / ubuntu) Specific:
```
# Install packages
sudo apt-get install -y build-essential zsh git wget curl nodejs ncal unzip xsel vim

# Install WezTerm from apt package manager
curl -fsSL https://apt.fury.io/wez/gpg.key | sudo gpg --yes --dearmor -o /usr/share/keyrings/wezterm-fury.gpg
echo 'deb [signed-by=/usr/share/keyrings/wezterm-fury.gpg] https://apt.fury.io/wez/ * *' | sudo tee /etc/apt/sources.list.d/wezterm.list
sudo apt update
sudo apt -y install wezterm

# Change shell to zsh
touch ~/.zshrc
chsh -s $(which zsh)

# Switch to zsh session
$(which zsh)

# Install homebrew (Link for more info: https://brew.sh/)
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Initialize homebrew for this session
eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"

# Install bundle with homebrew
brew bundle install --file Brewfile.linux

# Installing VSCode
VSCODE_DOWNLOAD=~/Downloads/vscode-latest.deb
curl -o "$VSCODE_DOWNLOAD" -L "https://code.visualstudio.com/sha/download?build=stable&os=linux-deb-x64"
sudo dpkg -i "$VSCODE_DOWNLOAD"
```

OS: OSX Spcific
```
# Install homebrew (Link for more info: https://brew.sh/)
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Initialize homebrew for this session
eval "$(${BREW_PREFIX}/bin/brew shellenv)"

# Install bundle with homebrew
brew bundle install --file Brewfile.osx
```

## Optional Dependencies

Rust
```
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
```

VSCode: https://code.visualstudio.com/download

## Install Configurations
```
./setup.sh
```

## Other OSX customizations:

### Fixing autocorrections in app - holy fucking shit is this problematic!:
```
defaults write NSGlobalDomain NSAutomaticSpellingCorrectionEnabled -bool false
defaults write NSGlobalDomain NSAutomaticCapitalizationEnabled -bool false
defaults write NSGlobalDomain NSAutomaticPeriodSubstitutionEnabled -bool false
defaults write NSGlobalDomain NSAutomaticDashSubstitutionEnabled -bool false
defaults write NSGlobalDomain NSAutomaticQuoteSubstitutionEnabled -bool false
defaults write NSGlobalDomain NSTextReplacementEnabled -bool false
```


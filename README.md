# nix-terminal-env

## Install Dependencies

OS: Linux (debian / ubuntu) Specific:
```
# Install packages
sudo apt-get install build-essential zsh git wget curl nodejs ncal unzip

# Change shell to zsh
chsh -s $(which zsh)

touch ~/.zshrc

# Switch to zsh session
$(which zsh)

# Install homebrew (Link for more info: https://brew.sh/)
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Initialize homebrew for this session
eval "$(${BREW_PREFIX}/bin/brew shellenv)"

# Install bundle with homebrew
brew bundle install --file Brewfile.linux
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

## Optional

Rust
```
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
```


# nix-terminal-env

## Dependencies

OS: Linux (debian / ubuntu) Specific:
```
sudo apt-get install build-essential zsh git wget curl nodejs ncal

# Change shell to zsh
chsh -s $(which zsh)

# Install bundle with homebrew
brew bundle install --file Brewfile.linux
```

OS: OSX Spcific
```
# Install bundle with homebrew
brew bundle install --file Brewfile.osx
```

Rust
```
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
```

## Configure symlinked configs
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

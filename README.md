# nix-terminal-env

## Dependencies

OS: Linux (debian / ubuntu) Specific:
```
sudo apt-get install zsh wget curl nodejs ncal

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

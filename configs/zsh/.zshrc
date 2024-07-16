if [[ "$(uname)" == "Darwin" ]]; then
  IS_DARWIN="true"
else
  IS_DARWIN="false"
fi

# Editor
export EDITOR="vi"
export K9S_EDITOR=vi
export TERM="xterm-256color"

# Quit bitching about commnets, stupid ZSH!
setopt interactivecomments

# Terraform bypass
alias tf_bypass='export TF_FORCE_LOCAL_BACKEND=1'

# Homebrew
if [[ "$IS_DARWIN" == "true" ]]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
else
  eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)" 
fi

# Linux version of OSX pbcopy and pbpaste.
alias pbcopy='xsel — clipboard — input'
alias pbpaste='xsel — clipboard — output'

# Cargo
source "$HOME/.cargo/env"

docker() {
    podman "$@"
}

# Enable vi mode
bindkey -v

# Edit command line directly in VIM
autoload -U edit-command-line
zle -N edit-command-line
bindkey '^E' edit-command-line                   # Opens Vim to edit current command line

# Search History
bindkey '^R' history-incremental-search-backward # Perform backward search in command line history
bindkey '^S' history-incremental-search-forward  # Perform forward search in command line history
#bindkey '^P' history-search-backward             # Go back/search in history (autocomplete)
#bindkey '^N' history-search-forward              # Go forward/search in history (autocomplete)

autoload -Uz add-zsh-hook
setopt prompt_subst

# Add Visual Studio Code (code)
code () { VSCODE_CWD="$PWD" open -n -b "com.microsoft.VSCode" --args $* ;}

# Include bin directory
export PATH=$PATH:/Users/$(whoami)/bin

# Use coreutils (installed via homebrew)
PATH="/usr/local/opt/coreutils/libexec/gnubin:$PATH"

# GO
export GOPATH=$HOME/go
export PATH=$PATH:$(go env GOPATH)/bin

### Krew (Kubectl)
export PATH="${KREW_ROOT:-$HOME/.krew}/bin:$PATH"

### Starship
eval "$(starship init zsh)"

# FZF
source <(fzf --zsh)

# aws profile selector
alias aws-profile='export AWS_PROFILE=$(aws configure list-profiles | fzf)'
# kubectl context selector
alias kubectx='kubectl config use-context $(kubectl config get-contexts -o name | fzf)'

# Display custom MOTD
if [ -f ~/.motd ]; then
    . ~/.motd
fi

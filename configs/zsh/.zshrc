# Choosing your custom prompt
CUST_PROMPT="powerlevel10k" # can be "starship" or "powerlevel10k"
typeset -g POWERLEVEL9K_INSTANT_PROMPT=off

# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ "$CUST_PROMPT" == "powerlevel10k" ]]; then
  if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
    source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
  fi
fi


if [[ "$(uname)" == "Darwin" ]]; then
  IS_DARWIN="true"
  BREW_PREFIX="/opt/homebrew"
else
  IS_DARWIN="false"
  BREW_PREFIX="/home/linuxbrew/.linuxbrew"
fi

# Editor
export EDITOR="vi"
export VISUAL="vi"
export K9S_EDITOR=vi
export TERM="xterm-256color"

# Include bin directory for personal scripts
export PATH=$PATH:/Users/$(whoami)/bin

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

# Quit bitching about commnets, stupid ZSH!
setopt interactivecomments

# Homebrew
if command -v ${BREW_PREFIX}/bin/brew &> /dev/null; then
  eval "$(${BREW_PREFIX}/bin/brew shellenv)"

  # Use coreutils (installed via homebrew)
  PATH="/usr/local/opt/coreutils/libexec/gnubin:$PATH"
else
  echo "ERROR: Please install homebrew"
fi

# Terraform bypass
alias tf_bypass='export TF_FORCE_LOCAL_BACKEND=1'

# Linux version of OSX pbcopy and pbpaste.
if ! command -v pbcopy &> /dev/null; then
  alias pbcopy='xsel -i --clipboard'
  alias pbpaste='xsel -o --clipboard'
fi

# Cargo (Rust)
if command -v cargo &> /dev/null; then
  source "$HOME/.cargo/env"
fi

# Alias docker to podman via function only if podman is installed and docker is not installed
if command -v podman &> /dev/null && ! command -v docker &> /dev/null; then
    docker() {
        podman "$@"
    }
fi

# Alias nerd-ls to ls if installed
if [ -L "$BREW_PREFIX/bin/nerd-ls" ] &> /dev/null; then
  alias ls='nerd-ls -i'
elif command -v lsd &> /dev/null ; then
  alias ls='lsd'
fi

# Add Visual Studio Code (code)
if [[ "$IS_DARWIN" == "true" ]]; then
    code () { VSCODE_CWD="$PWD" open -n -b "com.microsoft.VSCode" --args $* ;}
fi

# GO
if command -v go &> /dev/null; then
  export GOPATH=$HOME/go
  export PATH=$PATH:$(go env GOPATH)/bin
fi

### Kubectl
if command -v kubectl &> /dev/null; then
  # Krew
  export PATH="${KREW_ROOT:-$HOME/.krew}/bin:$PATH"

  # kubectl context selector
  alias kubectx='kubectl config use-context $(kubectl config get-contexts -o name | fzf)'

fi

### Starship
if [[ "$CUST_PROMPT" == "starship" ]]; then
  if command -v starship &> /dev/null; then
    eval "$(starship init zsh)"
  else
    echo "ERROR: Please install starship"
  fi
fi

# FZF
if command -v fzf &> /dev/null; then
  source <(fzf --zsh)
fi

# aws profile selector
alias aws-profile='export AWS_PROFILE=$(aws configure list-profiles | fzf)'
# Display custom MOTD
if [ -f ~/.motd ]; then
    . ~/.motd
fi

# Launching tmux on terminal startup
SUPPORTED_TMUX_TERMINALS=("iTerm.app" "WezTerm")
if command -v tmux &> /dev/null; then
   if [[ -n "$TERM_PROGRAM" && " ${SUPPORTED_TMUX_TERMINALS[*]} " == *" $TERM_PROGRAM "* ]]; then
    # Your code for supported terminals here

    # Find detached sessions and attach to the first one in the list
    OPEN_SESSIONS="$(tmux list-sessions | grep -v "(attached)")"
    if [ -n "$OPEN_SESSIONS" ]; then
      SESSION_ID=$(echo "$OPEN_SESSIONS" | awk '{print $1}' | sed -e 's/:$//' | head -n 1)
      echo "TMUX: Attaching to session: $SESSION_ID"
      exec tmux attach-session -t $SESSION_ID
    else
      # If no detached sessions are found, create a new one
      exec tmux new-session
    fi
    unset OPEN_SESSIONS SESSION_ID SUPPORTED_TMUX_TERMINALS
  fi
fi

if [[ "$CUST_PROMPT" == "powerlevel10k" ]]; then
  # To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
  [[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
  source "${BREW_PREFIX}/share/powerlevel10k/powerlevel10k.zsh-theme"
fi

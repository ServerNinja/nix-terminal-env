# Choosing your custom prompt
CUST_PROMPT="powerlevel10k" # can be "starship" or "powerlevel10k"

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
else
  IS_DARWIN="false"
fi

# Editor
export EDITOR="vi"
export VISUAL="vi"
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


# Alias docker to podman via function only if podman is installed and docker is not installed
if command -v podman &> /dev/null && ! command -v docker &> /dev/null; then
    docker() {
        podman "$@"
    }
fi

# Alias nerd-ls to ls if installed
if command -v nerd-ls &> /dev/null; then
  alias ls='nerd-ls -i'
fi

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
if [[ "$IS_DARWIN" == "true" ]]; then
    code () { VSCODE_CWD="$PWD" open -n -b "com.microsoft.VSCode" --args $* ;}
fi

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
if [[ "$CUST_PROMPT" == "starship" ]]; then
  eval "$(starship init zsh)"
fi

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

# Launching tmux on terminal startup
SUPPORTED_TMUX_TERMINALS=("iTerm.app" "WezTerm")
if command -v tmux &> /dev/null; then
  if [[ "${SUPPORTED_TMUX_TERMINALS[*]}" =~ "$TERM_PROGRAM" ]]; then
    # Your code for supported terminals here

    # Find detached sessions and attach to the first one in the list
    OPEN_SESSIONS="$(tmux list-sessions | grep -v "(attached)")"
    if [ -n "$OPEN_SESSIONS" ]; then
      SESSION_ID=$(echo "$OPEN_SESSIONS" | awk '{print $1}' | sed -e 's/:$//' | head -n 1)
      echo "TMUX: Attaching to session: $SESSION_ID"
      tmux attach-session -t $SESSION_ID
    else
      # If no detached sessions are found, create a new one
      tmux new-session
    fi
    unset OPEN_SESSIONS SESSION_ID SUPPORTED_TMUX_TERMINALS
  fi
fi

if [[ "$CUST_PROMPT" == "powerlevel10k" ]]; then
  source /opt/homebrew/share/powerlevel10k/powerlevel10k.zsh-theme
  
  # To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
  [[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
  source /opt/homebrew/share/powerlevel10k/powerlevel10k.zsh-theme
fi

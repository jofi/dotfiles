# Load custom configurations
export ZSH_CUSTOM=$HOME/.zsh

## use .localrc for SUPER SECRET CRAP that you don't
## want in your public, versioned repo.
if [[ -a $HOME/.localrc && $LOCALRC != "loaded" ]]
then
  echo "Loading $HOME/.localrc"
  source $HOME/.localrc
  export LOCALRC="loaded"
fi

## Zprof (uncomment for profiling purposes)
# zmodload zsh/zprof

# shortcut to this dotfiles path is $ZSH
export ZSH=$HOME/.oh-my-zsh

# Add custom functions and completions to fpath
# fpath=(~/.zsh/functions ~/.zsh/completions $fpath)
# autoload -U ~/.zsh/functions/*(:t)

## source every .zsh file in this rep
#for config_file ($ZSH/**/*.zsh) source $config_file
#
## initialize autocomplete here, otherwise functions won't be loaded
#autoload -U compinit
#compinit
#
## load every completion after autocomplete loads
#for config_file ($ZSH/**/completion.sh) source $config_file
#

#ZSH_THEME="robbyrussell"
ZSH_THEME="agnoster"

# Example aliases
# alias zshconfig="vim ~/.zshrc"
# alias ohmyzsh="vim ~/.oh-my-zsh"

# Set to this to use case-sensitive completion
# CASE_SENSITIVE="true"

# Comment this out to disable weekly auto-update checks
DISABLE_AUTO_UPDATE="true"

# Uncomment following line if you want to disable colors in ls
# DISABLE_LS_COLORS="true"

# Uncomment following line if you want to disable autosetting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment following line if you want red dots to be displayed while waiting for completion
# COMPLETION_WAITING_DOTS="true"

# Which plugins would you like to load? (plugins can be found in ~/.oh-my-zsh/plugins/*)
# Custom plugins may be added to ~/.oh-my-zsh/custom/plugins/
# Example format: plugins=(rails git textvim ruby lighthouse)

#plugins=(git python nvm git_jofi ssh-agent system_jofi)
plugins=(git jofi-custom jofi-git jofi-docker-functions ssh-agent direnv)

#zstyle :omz:plugins:ssh-agent agent-forwarding on
source $ZSH/oh-my-zsh.sh

#eval "$(direnv hook zsh)"
#autoload -U add-zsh-hook

#_conda_prompt_update() {
#  if [[ -n "$CONDA_DEFAULT_ENV" ]]; then
#    PROMPT="%{$fg[blue]%}($CONDA_DEFAULT_ENV)%{$reset_color%} $PROMPT"
#  fi
#}

#add-zsh-hook precmd _conda_prompt_update

if [[ "$TERM" == "xterm-256color" || "$TERM" == "screen-256color" ]]; then
  bindkey '\e[H' beginning-of-line
  bindkey '\e[F' end-of-line
  bindkey '\e[3~' delete-char
fi

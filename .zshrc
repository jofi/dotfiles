## Zprof (uncomment for profiling purposes)
# zmodload zsh/zprof

# shortcut to this dotfiles path is $ZSH
# export ZSH=$HOME/.dotfiles/zsh
export ZSH=$HOME/.oh-my-zsh

# your project folder that we can `c [tab]` to
export WORKSPACE=~/workspace

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
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"

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
# Example format: plugins=(rails git textmate ruby lighthouse)

plugins=(git python nvm git_jofi ssh-agent system_jofi)
zstyle :omz:plugins:ssh-agent agent-forwarding on
source $ZSH/oh-my-zsh.sh

# Load custom configurations
for config_file in ~/.zsh/{environment,functions,aliases}.sh; do
    [ -r "$config_file" ] && source "$config_file"
done

## use .localrc for SUPER SECRET CRAP that you don't
## want in your public, versioned repo.
if [[ -a ~/.localrc && $LOCALRC != "loaded" ]]
then
  source ~/.localrc
  export LOCALRC="loaded"
fi

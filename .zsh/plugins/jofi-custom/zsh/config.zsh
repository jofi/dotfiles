#if [[ -n $SSH_CONNECTION ]]; then
#  export PS1='%m:%3~$(git_info_for_prompt)%# '
#else
#  export PS1='%3~$(git_info_for_prompt)%# '
#fi

export LSCOLORS="exfxcxdxbxegedabagacad"
export CLICOLOR=true

#fpath=($ZSH/plugins/system_jofi/functions $fpath)

#autoload -U $(dirname $0)/../functions/*(:t)

HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000

setopt NO_BG_NICE # don't nice background tasks
setopt NO_HUP
setopt NO_LIST_BEEP
setopt LOCAL_OPTIONS # allow functions to have local options
setopt LOCAL_TRAPS # allow functions to have local traps
setopt HIST_VERIFY
setopt SHARE_HISTORY # share history between sessions ???
setopt EXTENDED_HISTORY # add timestamps to history
setopt PROMPT_SUBST
setopt CORRECT
setopt COMPLETE_IN_WORD
#setopt IGNORE_EOF

setopt APPEND_HISTORY # adds history
setopt INC_APPEND_HISTORY SHARE_HISTORY  # adds history incrementally and share it across sessions
setopt HIST_IGNORE_ALL_DUPS  # don't record dupes in history
setopt HIST_REDUCE_BLANKS

# don't expand aliases _before_ completion has finished
#   like: git comm-[tab]
setopt complete_aliases

zle -N newtab

    setopt auto_cd # Change dir without cd
    setopt extended_glob # Regex globbing
    setopt notify # Report the status if background jobs immediately
    setopt complete_in_word # Not just at the end
    setopt always_to_end # When complete from middle, move cursor
    setopt no_match # Show error if pattern has no matches
    setopt no_beep # Disable beeps
    setopt list_packed # Compact completion lists
    setopt list_types # Show types in completion
    setopt rec_exact # Recognize exact, ambiguous matches
    setopt hist_verify # When using ! cmds, confirm first
    setopt hist_ignore_all_dups # Ignore dups in command history
    setopt hist_ignore_space # Don't add commands prepended by whitespace to history
    setopt append_history # Allow multiple sessions to append to the history file
    setopt extended_history # Save additional info to history file
    setopt inc_append_history # Append commands to history immediately
    setopt prompt_subst # Enable variable substitution in prompt
    setopt correct # Command correction
    setopt short_loops # Allow short loops
    setopt auto_pushd # Automatically push directories onto dirstack
# }}}
# Keybindings {{{
    bindkey -v

    bindkey '^?' backward-delete-char
    bindkey '^[[1~' beginning-of-line # Home
    bindkey '^[[4~' end-of-line # End
    bindkey '^[[3~' delete-char # Del
    bindkey '^[[5~' up-line-or-history  # Page Up
    bindkey '^[[6~' down-line-or-history # Page Down
    bindkey "^[[7~" beginning-of-line # Home
    bindkey "^[[8~" end-of-line # End
    bindkey '^[[A' up-line-or-search # Up
    bindkey '^[[D' backward-char # Left
    bindkey '^[[B' down-line-or-search # Down
    bindkey '^[[C' forward-char # Right
    bindkey "^[OH" beginning-of-line
    bindkey "^[OF" end-of-line
    bindkey "^r" history-incremental-search-backward
    bindkey "^A" beginning-of-line
    bindkey "^E" end-of-line
    bindkey "^K" vi-change-eol
# }}}

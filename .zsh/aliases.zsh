alias df='df -h'

# Override oh-my-zsh git plugin: add full date to graph log
alias glog='git log --graph --decorate --format="%C(yellow)%h%Creset %C(auto)%d%Creset %s %C(cyan)%ad%Creset [%C(blue)%an%Creset]" --date=format:"%Y-%m-%d %H:%M"'
alias gloga='glog --all'
alias du='du -sh'
#alias reload!='. ~/.zshrc'
alias reload!='exec zsh'

alias be='bundle exec'
alias lic="cd ${WORKSPACE}/_license/license_generators/pc"
alias te='export $(tmux showenv SSH_AUTH_SOCK)'
alias fix-pom='mvn com.github.ekryd.sortpom:sortpom-maven-plugin:sort -Dsort.createBackupFile=false' 

# eza

if (( $+commands[eza] )); then
  alias ls='eza $eza_params'
  alias l='eza --git-ignore $eza_params'
  alias ll='eza --all --header --long $eza_params'
  alias llm='eza --all --header --long --sort=modified $eza_params'
  alias la='eza -lbhHigUmuSa'
  alias lx='eza -lbhHigUmuSa@'
  alias lt='eza --tree $eza_params'
  alias tree='eza --tree $eza_params'
fi

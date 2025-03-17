alias df='df -h'
alias du='du -sh'
alias reload!='. ~/.zshrc'

alias be='bundle exec'
alias lic="cd ${WORKSPACE}/_license/license_generators/pc"
alias te='export $(tmux showenv SSH_AUTH_SOCK)'
alias fix-pom='mvn com.github.ekryd.sortpom:sortpom-maven-plugin:sort -Dsort.createBackupFile=false' 

# eza
alias ls='eza $eza_params'
alias l='eza --git-ignore $eza_params'
alias ll='eza --all --header --long $eza_params'
alias llm='eza --all --header --long --sort=modified $eza_params'
alias la='eza -lbhHigUmuSa'
alias lx='eza -lbhHigUmuSa@'
alias lt='eza --tree $eza_params'
alias tree='eza --tree $eza_params'

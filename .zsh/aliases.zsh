alias df='df -h'
alias du='du -sh'
alias reload!='. ~/.zshrc'

alias be='bundle exec'
alias lic="cd ${WORKSPACE}/_license/license_generators/pc"
alias te='export $(tmux showenv SSH_AUTH_SOCK)'
alias fix-pom='mvn com.github.ekryd.sortpom:sortpom-maven-plugin:sort -Dsort.createBackupFile=false' 
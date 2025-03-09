# Workspace aliases
alias a8='cd ~/workspace/abis8'
alias adc='cd ~/workspace/abis8/abis8-docker-compose'
alias be='bundle exec'
alias wsetup='be rake application:setup; migrate'
alias applicants='be rake import:list_applicants'

# Git aliases
alias gloglog='git log --graph --pretty=format:'\''%Cred%h%Creset %an: %s - %Creset %C(yellow)%d%Creset %Cgreen(%ad)%Creset'\'' --abbrev-commit --date=short'
alias grs='git remote show origin'
alias gclean='git reset --hard HEAD; git clean -d -f'

# Docker aliases
alias dbe='docker-compose run --rm app bundle exec'
alias dtest='docker-compose run --rm app bundle exec rake test'
alias ddb='docker-compose exec db psql -U accuracy_test -d accuracy_db_prod'
alias dmigrator='docker-compose run --rm app bundle exec ./scripts/migrator'
alias dconsole='docker-compose run --rm app bundle exec ./scripts/migrator console'
alias dapp='docker-compose run --rm app'

# Directory aliases
alias dl='cd ~/workspace/learning/deep_learning'
alias lic='cd ~/workspace/_license/license_generators/pc'

# Misc aliases
alias te='export $(tmux showenv SSH_AUTH_SOCK)'
alias pkb='personal-knowledge-base.sh'
alias fix-pom='mvn com.github.ekryd.sortpom:sortpom-maven-plugin:sort -Dsort.createBackupFile=false'
alias atoolkit='docker run -ti --rm registry.ba.innovatrics.net/cs/abis-toolkit' 
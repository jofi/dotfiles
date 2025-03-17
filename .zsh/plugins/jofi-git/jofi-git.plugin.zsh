# Use `hub` as our git wrapper:
#   http://defunkt.github.com/hub/
hub_path=$(which hub)
if [[ -f $hub_path ]]
then
  alias git=$hub_path
fi

# The rest of my fun git aliases
alias gl='git pull --prune'
alias glog="git log --graph --pretty=format:'%Cred%h%Creset %an: %s - %Creset %C(yellow)%d%Creset %Cgreen(%ad)%Creset' --abbrev-commit --date=relative"
alias gshow="git show"
alias gp='git push origin HEAD'
alias gd='git diff'
alias gc='git commit'
alias gca='git commit -a'
alias gco='git checkout'
alias gb='git branch'
alias gs='git status' # upgrade your git if -sb breaks for you. it's fun.
alias grm="git status | grep deleted | awk '{print \$3}' | xargs git rm"
alias gloglog='git log --graph --pretty=format:'\''%Cred%h%Creset %an: %s - %Creset %C(yellow)%d%Creset %Cgreen(%ad)%Creset'\'' --abbrev-commit --date=short'
alias grs='git remote show origin'
alias gclean='git reset --hard HEAD; git clean -d -f'

# Uses git's autocompletion for inner commands. Assumes an install of git's
# bash `git-completion` script at $completion below (this is where Homebrew
# tosses it, at least).
completion=/usr/local/etc/bash_completion.d/git-completion.bash

if test -f $completion
then
  source $completion
fi


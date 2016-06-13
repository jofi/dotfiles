# shortcut to this dotfiles path is $ZSH
export ZSH=$HOME/.dotfiles/zsh

# your project folder that we can `c [tab]` to
export WORKSPACE=~/workspace
export PROJECTS=$WORKSPACE/_projects
export PRODUCTS=$WORKSPACE/_products

# source every .zsh file in this rep
for config_file ($ZSH/**/*.zsh) source $config_file

# initialize autocomplete here, otherwise functions won't be loaded
autoload -U compinit
compinit

# load every completion after autocomplete loads
for config_file ($ZSH/**/completion.sh) source $config_file

# use .localrc for SUPER SECRET CRAP that you don't
# want in your public, versioned repo.
# if [[ (-a ~/.localrc) && ($LOCALRC != loaded) ]]
if [[ -a ~/.localrc ]]
then
  source ~/.localrc
fi


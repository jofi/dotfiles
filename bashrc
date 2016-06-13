# This is just placeholder if you don't intend to use system's ~/.bashrc
# Othervise add this the following two lines to the end of original system ~/.bashrc

if [ -f ~/.bashrc_jofi ]; then
  source ~/.bashrc_jofi
fi

PATH=$PATH:$HOME/.rvm/bin # Add RVM to PATH for scripting
